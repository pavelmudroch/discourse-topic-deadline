import { apiInitializer } from "discourse/lib/api";
import { withPluginApi } from "discourse/lib/plugin-api";
import { getSiteSettings } from "../../lib/get-site-settings";
import { TopicDeadline } from "../components/topic-deadline";

export default apiInitializer("1.34", (api) => {
	try {
		const siteSettings = withPluginApi("1.34", (api) => getSiteSettings(api));
		if (!siteSettings.deadlineEnabled) {
			console.log("Deadline plugin is disabled.");
			return;
		}

		// api.renderInOutlet("above-topic-list-item", TopicDeadline);
		api.renderInOutlet("topic-list-before-link", TopicDeadline);
	} catch (error) {
		console.error(error);
	}
});
