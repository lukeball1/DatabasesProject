import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { AnimatePresence, motion } from "framer-motion";
import './Signup.css';

function Signup () {
    //api target and environment var
    const api = import.meta.env.VITE_API_URL;
    const navigate = useNavigate();


    //discern between student, faculty/staff, and visitor
    const [role, setRole] = useState("");

    //determine if graduated in the first place
    const [hasGraduated, setHasGraduated] = useState(false);

    //graduation month logic
    const [semester, setSemester] = useState("");
    const [year, setYear] = useState("");

    //create semesters options
    const semesters = ["Fall", "Spring", "Summer"]; 
    //create years range for student graduation
    const currentYear = new Date().getFullYear();
    const years = Array.from({ length: 5}, (_, i) => currentYear + i);

    //create staff years range
    const staffCurrentYear = new Date().getFullYear();
    const staffYears = Array.from({ length: 61}, (_, i) => staffCurrentYear - 60 + i);

    //variables to control signup information:
    const [fname, setFname] = useState("");
    const [lname, setLname] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");

    // Student fields
    const [studentID, setStudentID] = useState("");
    const [major, setMajor] = useState("");

    // Staff fields
    const [staffID, setStaffID] = useState("");
    const [department, setDepartment] = useState("");
    const [officeNumber, setOfficeNumber] = useState("");
    const [staffStartYear, setStaffStartYear] = useState("");

    // Visitor fields
    const [reason, setReason] = useState("");
    const [organization, setOrganization] = useState("");

    //function to handle signup processing
    async function handleSignup(e){
        e.preventDefault();

        //extra fields determined on spot
        let extra1 = null;
        let extra2 = null;
        let extra3 = null;

        if (role === "student"){
            extra1 = year;
            extra2 = major;
            extra3 = studentID;
        }

        else if (role ==="staff"){
            extra1 = staffID;
            extra2 = department;
        }

        else if (role ==="visitor"){
            extra1 = reason;
            extra2 = organization;
        }

        const body = {
            email,
            password,
            fname,
            lname,
            type: role,
            extra1,
            extra2,
            extra3,
            hasGraduated: hasGraduated,
        };

            try {
                const res = await fetch(`${api}/create_account`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify(body),
                });

                const result = await res.json();

                if (result.success) {
                    alert("Account created successfully!");
                    // Optionally redirect:
                    navigate("/login");
                } else {
                    alert("Error: " + result.error);
                }
            } catch (err) {
                console.error("Signup error:", err);
                alert("An unexpected error occurred.");
            }

    } 

    return (
        <div className="signup">
            <h2>Sign Up</h2>

            <form onSubmit={handleSignup}>
                <div className="basic-info">
                    <div className="names">
                        <input type="text" placeholder="First Name" value={fname} onChange={(e) => setFname(e.target.value)}/>
                        <input type="text" placeholder="Last Name" value={lname} onChange={(e) => setLname(e.target.value)}/>
                    </div>
                    
                    <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)}/>
                    <input type="password" placeholder="New Password" value={password} onChange={(e) => setPassword(e.target.value)}/>
                </div>

                <div className="role-selection">
                    <label>Who are you? </label>
                    <select value={role} onChange={(e) => setRole(e.target.value)}>
                        <option value={""}>Select one...</option>
                        <option value="student">Student</option>
                        <option value="staff">Staff/Faculty</option>
                        <option value="visitor">Visitor</option>
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
                                <input type="text" placeholder="Student ID" value={studentID} onChange={(e) => setStudentID(e.target.value)}/>
                                <input type="text" placeholder="Major" value={major} onChange={(e) => setMajor(e.target.value)}/>
                                <div className="graduation">
                                    <label>Have you graduated?</label>
                                    <input type="checkbox" checked={hasGraduated}  onChange={(e) => setHasGraduated(e.target.checked)}/>
                                </div>
                                {hasGraduated === false && (
                                    <div className="expected-graduation">
                                    <label>Expected Graduation: </label>
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
                                </div>
                                )}
                                
                                
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
                                <input type="text" placeholder="Staff/Faculty ID" value={staffID} onChange={(e) => setStaffID(e.target.value)}/>
                                <input type="text" placeholder="Department" value={department} onChange={(e) => setDepartment(e.target.value)}/>
                                <input type="text" placeholder="Office Number" value={officeNumber} onChange={(e) => setOfficeNumber(e.target.value)}/>
                                <label>What year did you start at S&T?</label>
                                <select id="staffYear" value={staffStartYear} onChange={(e) => setStaffStartYear(e.target.value)}>
                                    <option value="" >Year</option>
                                    {staffYears.map((y) => (
                                        <option key={y} value={y}>
                                            {y}
                                        </option>
                                    ))}
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
                                <input type="text" placeholder="Reason for Visit" value={reason} onChange={(e) => setReason(e.target.value)}/>
                                <input type="text" placeholder="Organization (optional)" value={organization} onChange={(e) => setOrganization(e.target.value)}/>
                            </motion.div>
                            )}
                    </AnimatePresence>
                </div>
                <button type="submit">Sign up</button>
            </form>
        </div>
    )
}

export default Signup;