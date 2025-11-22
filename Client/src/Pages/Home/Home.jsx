import { Router, Link } from "react-router-dom";
import Basicreviews from "../../assets/Basicreviews.js";
import './Home.css'

function Home() {
    return(
        <>
            <div className="title">
                <h1>The highest rated buildings on campus:</h1>
            </div>
            <div className="review-container">
                {/* ask server to query database to return 3 highest rated buildings */}
                {Basicreviews.map((review, index) => {
                    return(<div className="review">
                            <Link to={'/building/:buildingID'}><img key={index} src={review.r_img} style={{cursor: 'pointer'}}/></Link>
                            <p>Building name: {review.r_bldingName}</p>
                            <p>Rating: {review.r_rating}</p>
                        </div>)
                })}
            </div>
        </>
    );
}

export default Home;