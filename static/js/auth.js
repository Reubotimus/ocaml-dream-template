import { supabase } from "./supabaseClient.js";

// redirect to this page after successful login
const SUCCESS_LOGIN_REDIRECT = "/protected"

// set login token if logged in on initial page load
{
	const session = await getSession()
	if (session) {
		await addAuthCookie(session)
	}
}

// update auth cookie when session is updated by supabase
supabase.auth.onAuthStateChange(async (event, session) => {
	if (event === "SIGNED_OUT" || event === "USER_DELETED") {
		removeAuthCookie()
		return
	}
	if (session) {
		await addAuthCookie(session)
	}
})

// wire in the login form
wireLoginForm()

// set auth cookie using the backend
async function addAuthCookie(session) {
	if (!session?.access_token) {
		return
	}
	const res = await fetch("/auth/session", {
		method: "POST",
		headers: { "content-type": "application/json" },
		body: JSON.stringify({ access_token: session.access_token })
	})
	if (!res.ok) {
		console.error(`failed to set login token cookie. Failed with status ${res.status}`, res)
	}
}

// remove login auth cookie i.e. log out
async function removeAuthCookie() {
	const res = await fetch("/auth/logout", { method: "POST" })
	if (!res.ok) {
		console.error(`Failed to clear login token cookie. Failed with status ${res.status}`, res)
		return
	}
}

// wires the supabase login logic to the login form if found
async function wireLoginForm() {
	// get form if not found return silently
	const form = getId("login-form")
	if (!form) {
		return
	}

	form.addEventListener("submit", async (e) => {
		e.preventDefault()

		// disable submit button to disable resubmissions
		const submitButton = getId("login-submit")
		if (!submitButton) {
			console.error("unable to find submit button")
			return
		}
		submitButton.disabled = true

		try {
			// get email and password, ensure not empty
			const emailInput = getId("login-email")
			const passwordInput = getId("login-password")
			const email = (emailInput?.value ?? "").trim()
			const password = (passwordInput?.value ?? "").trim()
			if (!email || !password) {
				console.error("email or password was empty")
				return
			}

			// login and sync cookie
			const { data, error } = await logIn(email, password)
			if (error || !data?.session) {
				setLoginError(error)
				console.warn("login failed", error)
				return
			}
			await syncCookie(data.session)
		} catch (error) {
			console.warn("error logging in", error)
		} finally {
			submitButton.disabled = false
		}

		// redirect to success url
		window.location.href = SUCCESS_LOGIN_REDIRECT
	})
}

// gets the login session of the user
async function getSession() {
	const { data, error } = await supabase.auth.getSession()
	if (error) {
		console.warn("error getting logged in status", error)
		return null
	}
	const session = data.session
	if (session) {
		return session
	}
	return null
}

// call the supabase login method
function logIn(email, password) {
	return supabase.auth.signInWithPassword({ email, password })
}

// get element by id
function getId(elementId) {
	return document.getElementById(elementId)
}
