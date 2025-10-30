import { Link } from 'react-router-dom';
import './Navbar.css'
import SNT_logo from '../../assets/S&T_review_logo_trans.png'
import default_profile from '../../assets/empty_profile.svg'
import searchIcon from '../../assets/searchIcon.png'


function Navbar() {

    return (
        <div className="Navbar">
            <Link to={"/"} className='logo'><img className='logo' src={SNT_logo} /></Link>
            <div className="search">
                <input className='searchBar' placeholder='Search for a building...' type='text'></input> 
                <img src={searchIcon}/>
            </div>
            
            <Link to={"/login"}><img className='profile' src={default_profile}/></Link>
        </div>
    )
}

export default Navbar