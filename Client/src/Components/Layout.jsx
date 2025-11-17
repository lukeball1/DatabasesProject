import Navbar from './Navbar/Navbar';
import Footer from './Footer/Footer';
import { Outlet } from "react-router-dom";

function Layout() {
    return(
        <div className="app-layout">
            <Navbar />
            <main>
                <Outlet />
            </main>
            <Footer />
        </div>
    )
}

export default Layout