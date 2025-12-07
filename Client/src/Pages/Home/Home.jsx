import { useState, useEffect } from "react";
import { Router, Link } from "react-router-dom";
import Basicreviews from "../../assets/Basicreviews.js";
import './Home.css'

function Home() {
    //api base url
    const api = import.meta.env.VITE_API_URL;
    const [topRatedBuildings, setTopRatedBuildings] = useState([]);

    useEffect(() => {
        async function loadTopRated(){
            try {
                const result = await fetch(`${api}/top-buildings`);
                const data = await result.json();

                if (data.success) {
                    setTopRatedBuildings(data.data);
                }
            } catch (err) {
                console.error("Error fetching top buildings:", err);
            }
        }
        loadTopRated();
    }, [])

    return (
        <>
            <div className="title">
                <h1>The highest rated buildings on campus:</h1>
            </div>

            <div className="review-container">
                {topRatedBuildings.map((b, index) => {
                    // Build image URL
                    const imageURL = `${api}/static/building_images/${b.image_name}`;

                    // Encode building name for router (spaces → %20 or _ depending on your routing)
                    const encodedName = encodeURIComponent(b.name);

                    return (
                        <Link to={`/buildings/${encodedName}`}>
                            <div key={index} className="review">
                                <img
                                    src={imageURL}
                                    alt={b.name}
                                    className="building-img"
                                    style={{ cursor: "pointer" }}
                                />
                                <p>Building name: {b.name}</p>
                                <p>Rating: {b.rating.toFixed(1)}</p>
                            </div>
                        </Link>
                    );
                })}
            </div>
        </>
    );
}

export default Home;