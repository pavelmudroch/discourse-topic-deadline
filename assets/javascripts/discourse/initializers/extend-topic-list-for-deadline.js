import TopicListItem from "discourse/components/topic-list-item";
import { withPluginApi } from "discourse/lib/plugin-api";
import { getDeadlineRemainingDays } from "../../lib/get-deadline-remaining-days";
import { getDeadlineRemainingDaysClass } from "../../lib/get-deadline-remaining-days-class";
import { getSiteSettings } from "../../lib/get-site-settings";
import { translateDeadlineRemainingDays } from "../../lib/translate-deadline-remaining-days";

async function waitForApiReady(callback) {
	let retryCount = 0;
	let apiReady = false;

	while (retryCount++ < 10) {
		console.log("waiting for api...");
		try {
			if (window.requirejs && requirejs.entries["discourse/lib/plugin-api"]) {
				const { withPluginApi } = require("discourse/lib/plugin-api");

				withPluginApi("1.0.0", () => {
					console.log("api is ready");
					apiReady = true;
				});
			}

			if (apiReady) {
				callback();
				return;
			}
		} catch {
			const delay = 1_000 * 2 ** (retryCount - 1);
			await new Promise((resolve) => setTimeout(resolve, delay));
		}
	}
	console.error("Failed to get plugin API after multiple attempts");
}

const deprecated = true;

waitForApiReady(() => {
	if (deprecated) {
		return;
	}
	console.log(
		"[deadline-plugin] Initializing deadline display in topic list...",
	);
	const siteSettings = withPluginApi("1.0.0", (api) => getSiteSettings(api));
	if (!siteSettings.deadlineEnabled) {
		console.log("Deadline plugin is disabled.");
		return;
	}

	console.log(
		"[deadline-plugin] Deadline plugin is enabled. Extending TopicListItem...",
	);
	TopicListItem.reopen({
		didRender(...rest) {
			console.log("[deadline-plugin] Rendering TopicListItem...");
			this._super(...rest);
			const category = this.topic.category_id;
			const closed = this.topic.closed;
			const solved = this.topic.has_accepted_answer === true;
			const categoryIncluded =
				siteSettings.deadlineAllowedCategories?.includes(category) ?? true;

			if (!categoryIncluded) return;

			if (!siteSettings.deadlineDisplayOnClosedTopic && closed) return;

			if (!siteSettings.deadlineDisplayOnSolvedTopic && solved) return;

			this.addCustomElement();
		},

		addCustomElement() {
			console.log(
				"[deadline-plugin] Adding custom element to TopicListItem...",
			);
			if (!this.topic.deadline_timestamp) return;
			if (this.element.querySelector("span.topic-deadline-date")) return;

			const deadlineTimestamp = Number.parseInt(this.topic.deadline_timestamp);
			const deadlineRemainingDays = getDeadlineRemainingDays(deadlineTimestamp);
			const deadlineColorClass = getDeadlineRemainingDaysClass(
				deadlineRemainingDays,
				siteSettings.deadlineSoonDaysThreshold,
			);
			const topicDeadline = document.createElement("span");
			const deadlineDate = new Date(deadlineTimestamp);
			const timestampFormatted = deadlineDate.toLocaleDateString("cs-CZ", {
				year: "numeric",
				month: "long",
				day: "numeric",
			});
			const deadlineDayFormatted = translateDeadlineRemainingDays(
				deadlineRemainingDays,
			);
			const deadlineContent = `${
				deadlineDayFormatted?.concat(" - ") ?? ""
			}${timestampFormatted}`;
			topicDeadline.classList.add("topic-deadline-date", deadlineColorClass);

			if (this.topic.closed)
				topicDeadline.classList.add("topic-closed-deadline");

			topicDeadline.innerHTML = `<svg style="fill: currentColor;" class="d-icon svg-icon"><use href="#far-clock"></use></svg>${deadlineContent}`;
			const mainLink = this.element.querySelector(".main-link");
			mainLink.appendChild(topicDeadline);
		},
	});
});
