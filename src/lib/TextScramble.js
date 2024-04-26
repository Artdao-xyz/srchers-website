export default class TextScramble {
    constructor(el, text, scramblingDuration = 5) {
        this.el = el;
        this.chars = '!<>-_\\/[]{}—=+*^?#________';
        this.duration = 300; // Default duration for settling
        this.scramblingDuration = scramblingDuration;
        this.text = text;
    }

    async start() {
        await this.setText(this.text);
    }

    setText(text) {
        return new Promise((resolve) => {
            const oldText = this.el.innerText;
            const length = Math.max(oldText.length, text.length);
            const promise = new Promise((resolve) => (this.resolve = resolve));
            this.queue = [];

            // Calculate the duration for each character to settle
            const settlingDuration = this.duration;

            // Create a random start time for the whole word scrambling
            const scramblingStart = 0;

            for (let i = 0; i < length; i++) {
                const from = oldText[i] || '';
                const to = text[i] || '';

                // Calculate start and end times for each character
                const start = scramblingStart; // All characters start scrambling at the same time
                const end = start + settlingDuration * (i + 1); // Each letter settles in order

                this.queue.push({ from, to, start, end });
            }

            cancelAnimationFrame(this.frameRequest);
            this.frame = 0;
            this.update(resolve);
        });
    }

    async update(resolve) {
        let output = '';
        let complete = 0;
        for (let i = 0, n = this.queue.length; i < n; i++) {
            let { from, to, start, end, char } = this.queue[i];
            if (this.frame >= end) {
                complete++;
                output += to;
            } else if (this.frame >= start) {
                if (!char || Math.random() < 0.10) {
                    char = this.randomChar();
                    this.queue[i].char = char;
                }
                output += `<span class="dud">${char}</span>`;
            } else {
                output += from;
            }
        }
        this.el.innerHTML = output;
        if (complete === this.queue.length) {
            this.frame = 0;
            resolve();
        } else {
            this.frameRequest = requestAnimationFrame(() => this.update(resolve));
            this.frame += this.scramblingDuration; // Increment frame by scramblingDuration
        }
    }

    randomChar() {
        return this.chars[Math.floor(Math.random() * this.chars.length)];
    }
}
