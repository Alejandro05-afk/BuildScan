import { Routes, Route } from 'react-router-dom'
import ConfirmPage from './pages/ConfirmPage'
import ResetPasswordPage from './pages/ResetPasswordPage'

export default function App() {
  return (
    <Routes>
      <Route path="/confirm" element={<ConfirmPage />} />
      <Route path="/reset-password" element={<ResetPasswordPage />} />
      <Route
        path="*"
        element={
          <div className="container">
            <div className="card">
              <h1>BuildScan</h1>
              <p>Página no encontrada.</p>
            </div>
          </div>
        }
      />
    </Routes>
  )
}
