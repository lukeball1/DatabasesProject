import './Navbar.css'
import SNT_logo from '../../assets/S&T_review_logo_trans.png'
import default_profile from '../../assets/empty_profile.svg'
import searchIcon from '../../assets/searchIcon.png'


function Navbar() {

    return (
        <div className="Navbar">
            <img className='logo' src={SNT_logo} onClick={() => window.location.reload()}/>
            <div className="search">
                <input className='searchBar' placeholder='Search for a building...'></input> 
                <img src={searchIcon}/>
            </div>
            
            <img className='profile' src={default_profile}/>
        </div>
    )
}

export default Navbar