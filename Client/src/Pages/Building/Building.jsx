import { useParams } from 'react-router-dom';
import Modal from "react-modal";
import { useState } from 'react';
import templateimg from '../../../../Server/static/building_images/havener.jpg';
import './Building.css';

Modal.setAppElement("#root");

function Building() {

    const buildingID = () => {
            const { buildingID } = useParams();
    }

    const [modalOpen, setModalOpen] = useState(false);
    const openModal = () => setModalOpen(true);
    const closeModal = () => setModalOpen(false);

    

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
                    <button onClick={openModal}>Write a Review</button>

            </div>
            <Modal
                isOpen={modalOpen} onRequestClose={closeModal}
                style={{
                    content: {
                        margin: "auto"
                    }
                }}>

            </Modal>
        </div>
    );
}

export default Building;