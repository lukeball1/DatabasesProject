import { Link, useNavigate } from 'react-router-dom';
import { useState } from 'react';
import './Login.css'
import logo from "../../assets/S&T_review_logo_trans.png"

function Login() {
    //api and environment variables
    const api = import.meta.env.VITE_API_URL;
    const navigate = useNavigate();

    //variables to track email and password values
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");

    //set to change when login endpoint is made
    async function handleSubmit (e) {
        e.preventDefault();

        const body = {
            email,
            password,
        };

        try{
            const res = await fetch(`${api}/login`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(body),
            });

            const result = await res.json();

            if (result.success) {
                //store authentication token in local browser storage
                localStorage.setItem("auth_token", result.auth_token);
                localStorage.setItem("user_reviewerID", email);
                alert("Logged in");
                navigate("/");
            } else {
                alert("Error: " + result.error);
            }
        }

        catch (err) {
            console.error("login error: ", err);
            alert(" login error ");
        }

    }

    return (
        <div className='login'>
            <div className="login-logo">
                <img alt='' src={logo}/>
                <h1>New to S&T Review? <Link to={"/signup"} >Sign up</Link></h1>
            </div>
            <form onSubmit={handleSubmit}>
                <div className="input-fields">
                    <input type='email' placeholder='Email' value={email} onChange={(e) => setEmail(e.target.value)}></input>
                    <input type='password' placeholder='Password' value={password} onChange={(e) => setPassword(e.target.value)}></input>
                    <button type='submit'>Login</button>
                </div>
            </form>
            
            
        </div>
    )
}
export default Login;