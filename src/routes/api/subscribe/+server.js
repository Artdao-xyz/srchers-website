import { json } from '@sveltejs/kit';
import { MAILCHIMP_API_KEY } from '$env/static/private';

const API_KEY = MAILCHIMP_API_KEY;
const LIST_ID = '6f099dd01d';
const URL = `https://us11.api.mailchimp.com/3.0/lists/${LIST_ID}/members`;

export async function POST({ request }) {
	const { email } = await request.json();

	let body = JSON.stringify({
		email_address: email,
		status: 'subscribed' // Use 'pending' to send a confirmation email
	});

	let response = await fetch(URL, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json',
			Authorization: 'Bearer ' + API_KEY
		},
		body
	});

	// console.log(response);

	if (response.ok) {
		return json({ success: true });
	} else {
		const errorText = await response.text();
		return json({ success: false, error: errorText });
	}
}
