import { useEffect, useState } from 'react'
import { supabase } from '../supabase'

export default function ConfirmPage() {
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [message, setMessage] = useState('Estamos confirmando tu cuenta...')

  useEffect(() => {
    confirmEmail()
  }, [])

  async function confirmEmail() {
    try {
      const params = new URLSearchParams(window.location.search)
      const tokenHash = params.get('token_hash')
      const type = params.get('type')

      if (!tokenHash || type !== 'email') {
        setStatus('error')
        setMessage('El enlace no contiene un token de confirmación válido.')
        return
      }

      const { data, error } = await supabase.auth.verifyOtp({
        token_hash: tokenHash,
        type: 'email',
      })

      if (error) {
        console.error('Error al confirmar correo:', error)
        setStatus('error')
        setMessage('El enlace es inválido, expiró o ya fue utilizado.')
        return
      }

      if (!data.user) {
        setStatus('error')
        setMessage('No fue posible obtener el usuario confirmado.')
        return
      }

      setStatus('success')
      setMessage(
        'Tu cuenta de BuildScan fue confirmada correctamente. Ya puedes iniciar sesión en la aplicación.'
      )

      await supabase.auth.signOut()
    } catch (error) {
      console.error(error)
      setStatus('error')
      setMessage('Ocurrió un problema al confirmar tu cuenta.')
    }
  }

  return (
    <div className="container">
      <div className="card">
        <div className="logo">BuildScan</div>

        {status === 'loading' && (
          <>
            <div className="spinner" />
            <p>{message}</p>
          </>
        )}

        {status === 'success' && (
          <>
            <div className="icon-success">&#10003;</div>
            <h1>Cuenta confirmada</h1>
            <p>{message}</p>
            <p className="subtext">Vuelve a la aplicación para continuar.</p>
          </>
        )}

        {status === 'error' && (
          <>
            <div className="icon-error">&#10007;</div>
            <h1>No pudimos confirmar tu cuenta</h1>
            <p>{message}</p>
            <p className="subtext">Intenta registrarte de nuevo desde la app.</p>
          </>
        )}
      </div>
    </div>
  )
}
