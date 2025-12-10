import { useParams, useNavigate } from 'react-router-dom';
import Modal from "react-modal";
import { useState, useEffect } from 'react';
// import templateimg from '../../../../Server/static/building_images/havener.jpg';
import closeIcon from '../../assets/closeIcon.svg';
import './Building.css';

Modal.setAppElement("#root");
// USE THIS FOR FETCHING FROM SERVER 
const api = import.meta.env.VITE_API_URL;

function Building() {

    //get the building name from url
    const { buildingID } = useParams();
    const buildingName = decodeURIComponent(buildingID);
    const navigate = useNavigate();

    const cleanName = buildingName.replace(/\s+/g, "");
    const image = buildingName.replace(/ /g, "_");
    const imageURL = `${api}/static/building_images/${image}.jpg`;  // or .png
    const loggedInReviewerID = localStorage.getItem("user_reviewerID");
    const authentToken = localStorage.getItem("auth_token");


    const [modalOpen, setModalOpen] = useState(false);
    const openModal = () => setModalOpen(true);
    const closeModal = () => setModalOpen(false);
    const [text, setText] = useState("");

    //building and review data
    const [buildingData, setBuildingData] = useState(null);
    const [features, setFeatures] = useState([]);
    const [reviews, setReviews] = useState([]);
    
    //write a review states
    const [rating, setRating] = useState(0);
    const [hoverRating, setHoverRating] = useState(0);
    const [sentReview, setSentReview] = useState(false);

    const [reviewRatings, setReviewRatings] = useState({});
    const [hoverReviewRatings, setHoverReviewRatings] = useState({});

    //Edit/Delete review functionality
    const [editModalOpen, setEditModalOpen] = useState(false);
    const [editReviewText, setEditReviewText] = useState("");
    const [editReviewStars, setEditReviewStars] = useState(5);
    const [editReviewID, setEditReviewID] = useState(null);
    const [userReview, setUserReview] = useState(null); // to test if user has reviewed before


    function openEditModal(review) {
        setEditReviewID(review.ReviewID);
        setEditReviewText(review.Description);
        setEditReviewStars(review.NumStars);
        setEditModalOpen(true);
    }

    async function saveEdit() {
        const token = localStorage.getItem("auth_token");
        if (!token) return alert("Not logged in.");

        const res = await fetch(`${api}/edit_review`, {
            method: "PUT",
            headers: { 
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`,
            },
            body: JSON.stringify({
                review_id: editReviewID,
                description: editReviewText,
                num_stars: editReviewStars,
                auth_token: authentToken,
            })
        });

        const result = await res.json();
        if (!result.success) {
            alert(result.error);
            return;
        }

        setEditModalOpen(false);
        setSentReview(true);
    }

    async function deleteReview(id) {
        if (!confirm("Delete this review?")) return;

        const token = localStorage.getItem("auth_token");
        if (!token) return alert("Not logged in.");

        const res = await fetch(`${api}/delete_review`, {
            method: "DELETE",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`,
            },
            body: JSON.stringify({ review_id: id, auth_token: token }),
        });

        const result = await res.json();
        if (!result.success) {
            alert(result.error);
            return;
        }

        setSentReview(true);
    }

    useEffect(() => {
        async function fetchBuilding() {
            try{
                const result = await fetch(`${api}/buildings/${buildingName}`);
                const data = await result.json();

                if (data.success) {
                    setBuildingData(data.building);
                    setFeatures(data.features);
                    setReviews(data.reviews);
                }
                else{
                    console.error("Error loading building:", data.error);
                }
                setSentReview(false);
            } catch (err) {
                console.error("Fetch error:", err);
            }
        }

        fetchBuilding();
    }, [buildingName, sentReview]);

    async function handleSubmit(e) {
        e.preventDefault();

        if (rating === 0) {
            alert("Please select a rating");
            return;
        }

        try {
            //get token and verify user
            const token = localStorage.getItem("auth_token");
            if (!token) {
                alert("You must be logged in to submit a review.");
                navigate("/login");
                return;
            }

            const verify = await fetch(`${api}/verify_token`, {
                method: "POST",
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({auth_token : token})
            });

            const verifyData = await verify.json();
            if(!verifyData.success) {
                alert("Session expired. Please log in again");
                navigate("/login");
                return;
            }

            const reviewerID = verifyData.reviewer_id;

            const response = await fetch(`${api}/add_review`, {
                method: "POST",
                headers: { "Content-Type": "application/json"},
                body: JSON.stringify({
                    review_id: crypto.randomUUID(),
                    num_stars: rating,
                    description: text,
                    reviewer_id: reviewerID,
                    building_name: buildingName
                })
            });

            const data = await response.json();
            if (data.success){
                alert("Review submitted!");
                setModalOpen(false);
                setText("");
                setRating(0);
            } else {
                alert("Error: " + data.error);
            }
            setSentReview(true);
        } catch (err) {
            console.error(err);
            alert("Failed to submit review");
        }

    }

    async function handleRateReview(reviewID, ratingValue) {
        try {
            const token = localStorage.getItem("auth_token");
            if (!token) {
                alert("You must be logged in to rate reviews.");
                navigate("/login");
                return;
            }

            // verify token → get reviewer ID
            const verify = await fetch(`${api}/verify_token`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ auth_token: token }),
            });

            const verifyData = await verify.json();
            if (!verifyData.success) {
                alert("Session expired. Please log in again.");
                navigate("/login");
                return;
            }

            const reviewerID = verifyData.reviewer_id;

            // Send rating to API
            const response = await fetch(`${api}/rate_review`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    reviewer_id: reviewerID,
                    review_id: reviewID,
                    rating: ratingValue,
                }),
            });

            const data = await response.json();
            if (!data.success) {
                alert("Error rating review: " + data.error);
                return;
            }

            alert("Thanks for rating this review!");

        } catch (err) {
            alert("Failed to rate review");
            console.error(err);
        }
    }

    useEffect(() => {
        const existing = reviews.find(r => r.ReviewerID === loggedInReviewerID);
        setUserReview(existing || null);
    }, [reviews, loggedInReviewerID]);


    return (
        <div className="building">
            <div className="content">
                <div className="left">
                    <img src={imageURL} alt={buildingName} />

                    <div className="building-details">
                        <h1>Name: {buildingName}</h1>

                        <h3>Special Features:</h3>
                        <ul>
                            {features.length === 0 ? (
                                <li>No features listed.</li>
                            ) : (
                                features.map((f, idx) => (
                                    <li key={idx}>{f.Name} — {f.Description}</li>
                                ))
                            )}
                        </ul>

                        <h3>
                            Average Rating:{" "}
                            {reviews.length > 0
                                ? (
                                    reviews.reduce(
                                        (sum, r) => sum + r.NumStars,
                                        0
                                    ) / reviews.length
                                ).toFixed(1)
                                : "No reviews"}
                        </h3>
                    </div>
                </div>

                <div className="right-reviews">
    {reviews.length === 0 ? (
        <p>No reviews yet.</p>
    ) : (
        reviews.map((rev, idx) => {

            const userRating = reviewRatings[rev.ReviewID] || 0;
            const hoverRating = hoverReviewRatings[rev.ReviewID] || 0;

            return (
                <div className="review" key={idx}>
                    {/* User's rating for the building */}
                    <h2>{"⭐".repeat(rev.NumStars)}</h2>

                    <p className="review-desc">{rev.Description}</p>
                    <p className="reviewer">
                        — {(rev.Fname && rev.Lname) ? `${rev.Fname} ${rev.Lname}` : "Unknown Reviewer"}
                    </p>

                    {/* --- Edit/Delete Buttons (only for review owner) --- */}
                    {rev.ReviewerID === loggedInReviewerID && (
                        <div className="review-owner-controls">
                            <button
                                className="edit-btn"
                                onClick={() => openEditModal(rev)}
                            >
                                Edit
                            </button>

                            <button
                                className="delete-btn"
                                onClick={() => deleteReview(rev.ReviewID)}
                            >
                                Delete
                            </button>
                        </div>
                    )}


                    {/* --- ⭐ Rate This Review Section --- */}
                    <div className="rate-review">
                        <p>Rate this review:</p>

                        {[1, 2, 3, 4, 5].map((star) => (
                            <span
                                key={star}
                                onClick={() => {
                                    setReviewRatings(prev => ({ ...prev, [rev.ReviewID]: star }));
                                    handleRateReview(rev.ReviewID, star);
                                }}
                                onMouseEnter={() =>
                                    setHoverReviewRatings(prev => ({ ...prev, [rev.ReviewID]: star }))
                                }
                                onMouseLeave={() =>
                                    setHoverReviewRatings(prev => ({ ...prev, [rev.ReviewID]: 0 }))
                                }
                                style={{
                                    cursor: "pointer",
                                    fontSize: "24px",
                                    color:
                                        star <= (hoverRating || userRating)
                                            ? "#FFD700"
                                            : "#CCC",
                                    paddingRight: "4px"
                                }}
                            >
                                ★
                            </span>
                        ))}
                    </div>
                </div>
            );
        })
    )}
</div>

            </div>

            <div className="review-button">
                {!userReview ? (
                <button onClick={() => setModalOpen(true)}>Write a Review</button>
            ) : (
                <button onClick={() => openEditModal(userReview)}>Edit Your Review</button>
            )}

                {/* <button onClick={() => setModalOpen(true)}>
                    Write a Review
                </button> */}
            </div>

            <Modal
                isOpen={modalOpen}
                onRequestClose={() => setModalOpen(false)}
                className="modal-content"
                overlayClassName="modal-overlay"
            >
                <div className="close-img">
                    <img src={closeIcon} alt="Close" onClick={() => setModalOpen(false)} />
                </div>

                <h1>Write a review for {buildingName}</h1>

                <form onSubmit={handleSubmit}>
                {/* ⭐ STAR RATING SECTION */}
                <div className="star-rating">
                    {[1, 2, 3, 4, 5].map((star) => (
                        <span
                            key={star}
                            onClick={() => setRating(star)}
                            onMouseEnter={() => setHoverRating(star)}
                            onMouseLeave={() => setHoverRating(0)}
                            style={{
                                cursor: "pointer",
                                fontSize: "32px",
                                color:
                                    star <= (hoverRating || rating)
                                        ? "#FFD700"
                                        : "#CCC"
                            }}
                        >
                            ★
                        </span>
                    ))}
                </div>

                {/* REVIEW TEXT AREA */}
                <div className="review-msg">
                    <label>Write Your Review</label>
                    <textarea
                        maxLength={256}
                        value={text}
                        onChange={(e) => setText(e.target.value)}
                        placeholder="Write your review here..."
                        rows="8"
                    ></textarea>

                    <div className="count-message">
                        <span id="current">{text.length}</span>
                        <span> / 256</span>
                    </div>
                </div>

                <input type="submit" value="Submit Review" />
            </form>
            </Modal>
            {/* --- EDIT REVIEW MODAL --- */}
            <Modal
                isOpen={editModalOpen}
                onRequestClose={() => setEditModalOpen(false)}
                className="modal-content"
                overlayClassName="modal-overlay"
            >
                <div className="close-img">
                    <img src={closeIcon} alt="Close" onClick={() => setEditModalOpen(false)} />
                </div>

                <h1>Edit Your Review</h1>

                {/* STAR SELECTOR */}
                <div className="star-rating">
                    {[1, 2, 3, 4, 5].map((star) => (
                        <span
                            key={star}
                            onClick={() => setEditReviewStars(star)}
                            style={{
                                cursor: "pointer",
                                fontSize: "32px",
                                color: star <= editReviewStars ? "#FFD700" : "#CCC"
                            }}
                        >
                            ★
                        </span>
                    ))}
                </div>

                {/* TEXT FIELD */}
                <textarea
                    maxLength={256}
                    value={editReviewText}
                    onChange={(e) => setEditReviewText(e.target.value)}
                    rows="8"
                    className='review-modal-textarea'
                />

                <div  className="review-modal-buttons" style={{ marginTop: "12px" }}>
                    <button onClick={() => setEditModalOpen(false)} style={{width: "4.5rem"}}>Cancel</button>
                    <button onClick={saveEdit} style={{ marginLeft: "10px"}}>
                        Save Changes
                    </button>
                </div>
            </Modal>

        </div>
    );
}

export default Building;