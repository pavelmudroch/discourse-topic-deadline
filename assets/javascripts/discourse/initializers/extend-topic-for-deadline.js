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

		console.log({ ...siteSettings });

		api.renderInOutlet("after-topic-list-item", TopicDeadline, {
			params: {
				deadlineDisplayOnClosedTopic: siteSettings.deadlineDisplayOnClosedTopic,
				deadlineDisplayOnSolvedTopic: siteSettings.deadlineDisplayOnSolvedTopic,
				deadlineAllowedCategories: siteSettings.deadlineAllowedCategories,
			},
		});
	} catch (error) {
		console.error(error);
	}
});
