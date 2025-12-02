import { useParams } from 'react-router-dom';
import Modal from "react-modal";
import { useState } from 'react';
// import templateimg from '../../../../Server/static/building_images/havener.jpg';
import closeIcon from '../../assets/closeIcon.svg';
import './Building.css';

Modal.setAppElement("#root");

function Building() {

    const buildingID = () => {
            const { buildingID } = useParams();
    }

    const [modalOpen, setModalOpen] = useState(false);
    const openModal = () => setModalOpen(true);
    const closeModal = () => setModalOpen(false);
    const [text, setText] = useState("");

    return (
        <div className="building">
            <div className='content'>
                <div className="left">
                    {/* <img src={templateimg} /> */}
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
                    <div className="review">
                        <h1> content</h1>
                    </div>
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
                className="modal-content" overlayClassName="modal-overlay">
                    <div className="close-img">
                        <img src={closeIcon} alt='Close icon' onClick={closeModal}/>
                    </div>
                    <h1>Write a review for /Building Name/</h1>
                    <form>
                        <div className="stars">
                            {/* map stars here */}
                            <h1> stars here</h1>
                        </div>

                        <div className="review-msg">
                            <label>Write Your Review</label>
                            <textarea name='review' maxlength={256} value = {text} onChange={(e) => setText(e.target.value)} placeholder='Write your review here...' rows='8'></textarea>
                            <div className="count-message">
                                <span id="current">{text.length}</span>
                                <span> / 256</span>
                            </div>
                        </div>

                        <input type='submit' value={"Submit Reivew"} ></input>
                    </form>
                    

            </Modal>
        </div>
    );
}

export default Building;