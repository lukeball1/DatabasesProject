import { Link, useNavigate } from 'react-router-dom';
import { useEffect, useState, useRef } from 'react';
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
    const navigate = useNavigate();

    useEffect(() => {
        async function loadBuildings(){
            try {
                const result = await fetch(`${api}/buildings`);
                const data = await result.json();

                setBuildings(data.buildings || []);
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
    }, [search, buildings]);

    const handleEnterPress = () => {
        setShowDropdown(false);
        if (filtered.length === 0) return;
        handleSelectBuilding(filtered[0]);
    };

    const handleSelectBuilding = (buildingName) => {
        setShowDropdown(false);
        setSearch(buildingName);
        //navigate to building page here
        if (!buildingName) return;
        navigate(`/buildings/${encodeURIComponent(buildingName.trim())}`);
    }

    const searchRef = useRef(null);
    useEffect(() => {
        function handleClickOutside(event) {
            if (searchRef.current && !searchRef.current.contains(event.target)) {
                // Clicked outside → close dropdown
                setShowDropdown(false);
            }
        }

        document.addEventListener("mousedown", handleClickOutside);
        return () => document.removeEventListener("mousedown", handleClickOutside);
    }, []);


    return (
        <div className="Navbar">
            <Link to={"/"} className='logo'><img className='logo' src={SNT_logo} /></Link>
            <div className="search" ref={searchRef}>
                <input className='searchBar' placeholder='Search for a building...' type='text'
                onChange={(e) => setSearch(e.target.value)}
                onFocus={() => setShowDropdown(true)}
                value={search}
                onKeyDown={(e) => {
                    if (e.key === "Enter") {
                        // implement this function to search
                        handleEnterPress();

                    }
                }}
                ></input> 
                <img src={searchIcon} onClick={() => handleEnterPress()}/>
                {/* dropdown */}
                {showDropdown && filtered.length > 0 && (
                    <ul className="search-dropdown">
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