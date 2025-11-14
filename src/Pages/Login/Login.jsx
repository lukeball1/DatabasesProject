import { Link } from 'react-router-dom';
import './Login.css'
import logo from "../../assets/S&T_review_logo_trans.png"

function Login() {
    return (
        <div className='login'>
            <div className="login-logo">
                <img alt='' src={logo}/>
                <h1>New to S&T Review? <Link to={"/sign-up"} >Sign up</Link></h1>
            </div>
            <div className="input-fields">
                <input type='email' placeholder='Email'></input>
                <input type='password' placeholder='Password'></input>
                <button>Login</button>
            </div>
            
        </div>
    )
}
export default Login;