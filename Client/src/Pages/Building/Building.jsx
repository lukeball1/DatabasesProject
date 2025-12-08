import { useParams } from 'react-router-dom';
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

    const cleanName = buildingName.replace(/\s+/g, "");
    const imageURL = `${api}/static/building_images/${buildingName}.jpg`;  // or .png

    const [modalOpen, setModalOpen] = useState(false);
    const openModal = () => setModalOpen(true);
    const closeModal = () => setModalOpen(false);
    const [text, setText] = useState("");

    //building and review data
    const [buildingData, setBuildingData] = useState(null);
    const [features, setFeatures] = useState([]);
    const [reviews, setReviews] = useState([]);


    // const reviewData = fetch(`${api}/buildings`);//find endpoint for specific building

    useEffect(() => {
        async function fetchBuilding() {
            try{
                const result = await fetch(`${apt}/buildings/${buildingName}`);
                const data = await result.json();

                if (data.success) {
                    setBuildingData(data.building);
                    setFeatures(data.features);
                    setReviews(data.review);
                }
                else{
                    console.error("Error loading building:", data.error);
                }
            } catch (err) {
                console.error("Fetch error:", err);
            }
        }
        fetchBuilding();
    }, [buildingName]);


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
                                    <li key={idx}>{f.Name}</li>
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

                {/* RIGHT SIDE REVIEWS */}
                <div className="right-reviews">
                    {reviews.length === 0 ? (
                        <p>No reviews yet.</p>
                    ) : (
                        reviews.map((rev, idx) => (
                            <div className="review" key={idx}>
                                <h2>⭐ {rev.NumStars}</h2>
                                <p className="review-desc">{rev.Description}</p>
                                <p className="reviewer">— {rev.ReviewerID}</p>
                            </div>
                        ))
                    )}
                </div>
            </div>

            <div className="review-button">
                <button onClick={() => setModalOpen(true)}>
                    Write a Review
                </button>
            </div>

            {/* REVIEW MODAL */}
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

                <form>
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
        </div>
    );
}

export default Building;