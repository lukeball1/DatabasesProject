import { useParams } from 'react-router-dom';
import templateimg from '../../../../Server/static/building_images/havener.jpg';
import './Building.css';

function Building() {

    const buildingID = () => {
            const { buildingID } = useParams();
    }

    return (
        <div className="building">
            <div className='content'>
                <div className="left">
                    <img src={templateimg} />
                    <div className="building-details">
                        <h1>Name: Havener</h1>
                        <h3>Special Features: ?</h3>
                        <h3> Average Rating: </h3>
                    </div>
                </div>
                <div className="right-reviews">
                    {/* map review information */}
                    <div className="review">
                        <h1> content</h1>
                    </div>
                </div>
            
            </div>
            <div className="review-button">
                    <button>Write a Review</button>
            </div>
        </div>
    );
}

export default Building;