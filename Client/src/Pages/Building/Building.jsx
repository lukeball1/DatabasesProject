import { useParams } from 'react-router-dom';
import './Building.css';

function Building() {

    const buildingID = () => {
            const { buildingID } = useParams();
    }

    return (
        <div className="building">

        </div>
    );
}

export default Building;