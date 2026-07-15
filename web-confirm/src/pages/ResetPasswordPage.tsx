import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { supabase } from '../supabase'

type ViewState = 'loading' | 'form' | 'submitting' | 'success' | 'error'

export default function ResetPasswordPage() {
  const [searchParams] = useSearchParams()
  const [view, setView] = useState<ViewState>('loading')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [errorMsg, setErrorMsg] = useState('')
  const [hasSession, setHasSession] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    const accessToken = searchParams.get('access_token')
    const refreshToken = searchParams.get('refresh_token')
    const type = searchParams.get('type')

    if (type === 'recovery' && accessToken && refreshToken) {
      supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: refreshToken,
      }).then(({ error }) => {
        if (error) {
          setView('error')
          setErrorMsg('El enlace de restablecimiento no es válido o ya expiró.')
        } else {
          setHasSession(true)
          setView('form')
        }
      })
    } else {
      setView('error')
      setErrorMsg('Enlace de restablecimiento inválido.')
    }
  }, [searchParams])

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setErrorMsg('')

    if (password.length < 6) {
      setErrorMsg('La contraseña debe tener al menos 6 caracteres.')
      return
    }
    if (password !== confirmPassword) {
      setErrorMsg('Las contraseñas no coinciden.')
      return
    }
    if (!hasSession) {
      setErrorMsg('Sesión no válida. Solicita un nuevo enlace.')
      return
    }

    setSubmitting(true)
    const { error } = await supabase.auth.updateUser({ password })

    if (error) {
      setSubmitting(false)
      setErrorMsg(error.message || 'No se pudo restablecer la contraseña.')
      return
    }
    setView('success')
  }

  return (
    <div className="container">
      <div className="card">
        <div className="logo">BuildScan</div>

        {view === 'loading' && (
          <>
            <div className="spinner" />
            <p>Verificando enlace...</p>
          </>
        )}

        {view === 'form' && (
          <>
            <h1>Nueva contraseña</h1>
            <p className="subtext">Escribe tu nueva contraseña abaixo.</p>
            <form onSubmit={handleSubmit}>
              <div className="input-group">
                <label htmlFor="password">Nueva contraseña</label>
                <div className="password-wrapper">
                  <input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="Mínimo 6 caracteres"
                    required
                    minLength={6}
                  />
                  <button
                    type="button"
                    className="toggle-password"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? 'Ocultar' : 'Ver'}
                  </button>
                </div>
              </div>
              <div className="input-group">
                <label htmlFor="confirm">Confirmar contraseña</label>
                <input
                  id="confirm"
                  type={showPassword ? 'text' : 'password'}
                  value={confirmPassword}
                  onChange={e => setConfirmPassword(e.target.value)}
                  placeholder="Repite la contraseña"
                  required
                  minLength={6}
                />
              </div>
              {errorMsg && <div className="error-msg">{errorMsg}</div>}
              <button type="submit" className="btn-primary" disabled={submitting}>
                {submitting ? 'Restableciendo...' : 'Restablecer contraseña'}
              </button>
            </form>
          </>
        )}

        {view === 'success' && (
          <>
            <div className="icon-success">&#10003;</div>
            <h1>Contraseña restablecida</h1>
            <p>Tu contraseña ha sido actualizada exitosamente.</p>
            <p className="subtext">Vuelve a la aplicación e inicia sesión con tu nueva contraseña.</p>
          </>
        )}

        {view === 'error' && (
          <>
            <div className="icon-error">&#10007;</div>
            <h1>Error</h1>
            <p>{errorMsg}</p>
            <p className="subtext">Solicita un nuevo enlace desde la app.</p>
          </>
        )}
      </div>
    </div>
  )
}
