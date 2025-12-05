import { Link } from 'react-router-dom';
import { useEffect, useState } from 'react';
import './Navbar.css'
import SNT_logo from '../../assets/S&T_review_logo_trans.png'
import default_profile from '../../assets/empty_profile.svg'
import searchIcon from '../../assets/searchIcon.png'


function Navbar() {

        const api = import.meta.env.VITE_API_URL;

    //search building logic
    const [buildings, setBuildings] = useState([]);
    const [search, setSearch] = useState("");
    const [filtered, setFiltered] = useState([]);
    const [showDropdown, setShowDropdown] = useState(false);

    useEffect(() => {
        async function loadBuildings(){
            try {
                const result = await fetch(`${api}/buildings`);
                const data = await result.json();

                setBuildings(data.buildings || []);
                console.log("buildings set");
                console.log(buildings);
                setFiltered(data.buildings || []); //initial value is the full list
            } catch (err){
                console.error("Error building functions", err);
            }
        }

        loadBuildings();
    }, [api]);

    useEffect(() => {
        //filter buildings whenever query or buildings change
        const lowerSearch = search.toLowerCase();
        setFiltered(buildings.filter((b) => b.toLowerCase().includes(lowerSearch)));
        console.log("Search is updated");
        console.log(buildings);
    }, [search, buildings]);

    const handleEnterPress = () => {
        console.log("User hit enter:" , search);
        setShowDropdown(false);
    };

    const handleSelectBuilding = (buildingName) => {
        setSearch(buildingName);
        setShowDropdown(false);
        //navigate to building page here
    }

    return (
        <div className="Navbar">
            <Link to={"/"} className='logo'><img className='logo' src={SNT_logo} /></Link>
            <div className="search">
                <input className='searchBar' placeholder='Search for a building...' type='text'
                onChange={(e) => setSearch(e.target.value)}
                onFocus={() => setShowDropdown(true)}
                onKeyDown={(e) => {
                    if (e.key === "Enter") {
                        // implement this function to search
                        handleEnterPress();
                    }
                }}
                ></input> 
                <img src={searchIcon}/>
                {/* dropdown */}
                {showDropdown ** filtered.length > 0 && (
                    <ul
                        className="search-dropdown"
                        style={{
                            position: "absolute",
                            top: "100%",
                            left: 0,
                            right: 0,
                            maxHeight: "200px",
                            overflowY: "auto",
                            backgroundColor: "white",
                            border: "1px solid #ccc",
                            zIndex: 1000,
                            padding: 0,
                            margin: 0,
                            listStyle: "none",
                        }}
                    >
                        {filtered.map((b) => (
                            <li key={b} style={{ padding: "0.5rem", cursor: "pointer" }}
                                onClick={() => handleSelectBuilding(b)}>{b}</li>
                        ))}
                    </ul>
                )}
            </div>
            {/* if user isn't logged in, link to login page. If user is logged in, create a profile page */}
            <Link to={"/login"}><img className='profile' src={default_profile}/></Link>
        </div>
    )
}

export default Navbar