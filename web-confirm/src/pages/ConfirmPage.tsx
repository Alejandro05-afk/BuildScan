import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { supabase } from '../supabase'

export default function ConfirmPage() {
  const [searchParams] = useSearchParams()
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [message, setMessage] = useState('')

  useEffect(() => {
    const token = searchParams.get('token')
    const type = searchParams.get('type')

    if (type === 'signup' && token) {
      supabase.auth.verifyOtp({ token_hash: token, type: 'signup' })
        .then(({ error }) => {
          if (error) {
            setStatus('error')
            setMessage('El enlace de confirmación no es válido o ya expiró.')
          } else {
            setStatus('success')
          }
        })
    } else {
      setStatus('success')
    }
  }, [searchParams])

  return (
    <div className="container">
      <div className="card">
        <div className="logo">BuildScan</div>
        {status === 'loading' && (
          <>
            <div className="spinner" />
            <p>Verificando tu cuenta...</p>
          </>
        )}
        {status === 'success' && (
          <>
            <div className="icon-success">&#10003;</div>
            <h1>Cuenta confirmada</h1>
            <p>Tu cuenta ha sido verificada exitosamente.</p>
            <p className="subtext">Vuelve a la aplicación para continuar.</p>
          </>
        )}
        {status === 'error' && (
          <>
            <div className="icon-error">&#10007;</div>
            <h1>Error</h1>
            <p>{message}</p>
            <p className="subtext">Intenta registrarte de nuevo desde la app.</p>
          </>
        )}
      </div>
    </div>
  )
}
