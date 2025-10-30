import './Login.css'
import logo from "../../assets/S&T_review_logo_trans.png"

function Login() {
    return (
        <div className='login'>
            <img alt='' src={logo}/>
            <input type='email' placeholder='Email'></input>
            <input type='password' placeholder='Password'></input>
            <button>Login</button>
        </div>
    )
}
export default Login;