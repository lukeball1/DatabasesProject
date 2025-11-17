import { useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import './Signup.css';

function Signup () {
    //discern between student, faculty/staff, and visitor
    const [role, setRole] = useState("");

    //graduation month logic
    const [semester, setSemester] = useState("");
    const [year, setYear] = useState("");

    //create semesters options
    const semesters = ["Fall", "Spring", "Summer"]; 
    //create years range for student graduation
    const currentYear = new Date().getFullYear();
    const years = Array.from({ length: 80}, (_, i) => currentYear - 70 + i);


    return (
        <div className="Signup">
            <h2>Sign Up</h2>

            <div className="basic-info">
                <div className="names">
                    <input type="text" placeholder="First Name"/>
                    <input type="text" placeholder="Last Name"/>
                </div>
                
                <input type="email" placeholder="Email"/>
                <input type="password" placeholder="New Password"/>

            </div>

            <div className="role-selection">
                <label>Who are you?</label>
                <select value={role} onChange={(e) => setRole(e.target.value)}>
                    <option value={""}>Select one...</option>
                    <option value="student">Current Student</option>
                    <option value="staff">Staff/Faculty</option>
                    <option value="visitor">Visitor/Alumni</option>
                </select>

                {/* sections */}

                <AnimatePresence mode="wait">
                    {role === "student" && (
                        <motion.div 
                            key="student"
                            initial={{ opacity: 0, y: -10}}
                            animate={{opacity: 1, y: 0}}
                            exit={{opacity: 0, y: -10}}
                            transition={{ duration: 0.25}}
                            className="role-section"
                        >
                            <h3>Student Info</h3>
                            <input type="text" placeholder="Student ID"/>
                            <input type="text" placeholder="Major"/>
                            <select className="grad-selection" value={semester} onChange={(e) => {
                                setSemester(e.target.value);
                                handleDateChange(e.target.value, year);
                            }}>
                                <option value="">Term</option>
                                {semesters.map((m, index) => (
                                    <option key={index} value={index + 1}>
                                        {m}
                                    </option>
                                ))}
                            </select>

                            <select value={year} onChange={(e) => {
                                setYear(e.target.value);
                            }}>
                                <option value="">Year</option>
                                {years.map((y) => (
                                    <option key={y} value={y}>
                                        {y}
                                    </option>
                                ))}    
                            </select>  
                        </motion.div>
                    )}

                    {role === "staff" && (
                        <motion.div
                            key="staff"
                            initial={{ opacity: 0, y: -10 }}
                            animate={{ opacity: 1, y: 0 }}
                            exit={{ opacity: 0, y: -10 }}
                            transition={{ duration: 0.25 }}
                            className="role-section"
                        >
                            <h3>Staff/Faculty Info</h3>
                            <input type="text" placeholder="Staff/Faculty ID"/>
                            <input type="text" placeholder="Department" />
                            <input type="text" placeholder="Office Number" />
                            <select>

                            </select>
                        </motion.div>
                        )}

                        {role === "visitor" && (
                        <motion.div
                            key="visitor"
                            initial={{ opacity: 0, y: -10 }}
                            animate={{ opacity: 1, y: 0 }}
                            exit={{ opacity: 0, y: -10 }}
                            transition={{ duration: 0.25 }}
                            className="role-section"
                        >
                            <h3>Visitor Info</h3>
                            <input type="text" placeholder="Reason for Visit" />
                            <input type="text" placeholder="Organization (optional)" />
                        </motion.div>
                        )}
                </AnimatePresence>

            </div>
        </div>
    )
}

export default Signup;