import Layout from "./Components/Layout";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Home from "./Pages/Home/Home";
import Login from "./Pages/Login/Login";
import Signup from "./Pages/Signup/Signup";
import Building from "./Pages/Building/Building";
import './App.css';

function App() {

  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<Signup />} />
          <Route path="/building/:buildingID" element={<Building/>}/>
        </Route>
      </Routes>
    </Router>
  )
}

export default App
