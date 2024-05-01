<script>

    let submitting = false;
	let success = false;
	let error = false;
	let memberExists = false;

    const handleSubmit = async (event) => {
        // console.log('submitting', submitting);
        submitting = true;
        event.preventDefault();
        const form = event.target;
        const formData = new FormData(form);
        const response = await fetch(form.action, {
            method: form.method,
            body: JSON.stringify({
                email: formData.get('EMAIL')
            }),
            headers: {
                Accept: 'application/json'
            }
        });
        const data = await response.json();
        // @dev has shape { success : true }
        // console.log(data);
        if (data.success) {
            success = true;
        } else {
            const errorType = JSON.parse(data.error);
            const errorTitle = errorType.title;
            // console.error(errorTitle);
            if (errorTitle === 'Member Exists') {
                memberExists = true;
            } else {
                error = true;
            }
        }
        submitting = false;
        // console.log(submitting);
        setTimeout(() => {
            success = false;
            memberExists = false;
            error = false;
        }, 4000);
    };

</script>

<form 
    on:submit|preventDefault={handleSubmit}
    method="POST"
    action="/api/subscribe"
    id="subscribeForm"
    class="flex gap-6">

    <input type="email"
        name="EMAIL"
        required
        value=""
        placeholder="ENTER EMAIL"
        class="bg-transparent text-base lg:text-lg font-bold tracking-wide uppercase placeholder:text-alternative-black border-b-[1px] border-alternative-black outline-none rounded-none w-56"
    />

    <button type="submit"><img src="/submit.svg" alt="submit"></button>

    <div aria-hidden="true" style="position: absolute; left: -5000px;">
        <!-- /* real people should not fill this in and expect good things - do not remove this or risk form bot signups */ -->
        <input type="text" name="b_d150dd71762335c56d7e5811c_6f099dd01d" tabindex="-1" value="" />
    </div>
</form>

<div class="text-primary text-center italic flex items-center justify-start gap-4 mt-4">
    {#if submitting}
        <p class="text-xs lg:text-sm mx-auto">Submitting...</p>
        {:else if success}
        <p class="text-xs lg:text-sm tracking-wider">Welcome to the SRCH
        </p>
        {:else if memberExists}
        <p class="text-xs lg:text-sm tracking-wider">You're already subscribed!</p>
        {:else if error}
        <p class="text-xs lg:text-sm tracking-wider">
            Something went wrong, please try again.
        </p>
        {/if}
</div>