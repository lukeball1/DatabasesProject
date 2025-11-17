import { useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import './Signup.css';

function Signup () {

    const [role, setRole] = useState("");

    return (
        <div className="Signup">
            <h2>Sign Up</h2>

            <div className="role-selection">
                <label>Who are you?</label>
                <select value={role} onChange={(e) => setRole(e.target.value)}>
                    <option value={""}>Select one...</option>
                    <option value="student">Student</option>
                    <option value="staff">Staff/Faculty</option>
                    <option value="visitor">Visitor</option>
                </select>
            </div>
        </div>
    )
}

export default Signup;