import { apiInitializer } from "discourse/lib/api";
import { withPluginApi } from "discourse/lib/plugin-api";
import { getSiteSettings } from "../../lib/get-site-settings";
import { TopicDeadline } from "../components/topic-deadline";

console.log("Initializing extend-topic-for-deadline...");
export default apiInitializer("1.34", (api) => {
	try {
		console.log("Rendering TopicDeadline component...");
		api.renderInOutlet("after-topic-list-item", TopicDeadline);
		console.log(TopicDeadline);

		const siteSettings = withPluginApi("1.34", (api) => getSiteSettings(api));
		if (!siteSettings.deadlineEnabled) {
			console.log("Deadline plugin is disabled.");
			return;
		}
		console.log(siteSettings);
	} catch (error) {
		console.error(error);
	}

	// api.renderInOutlet("after-topic-list-item", (outletArgs) => {
	// 	const topic = outletArgs.topic;

	// 	const category = topic.category_id;
	// 	const closed = topic.closed;
	// 	const solved = topic.has_accepted_answer === true;
	// 	const categoryIncluded =
	// 		siteSettings.deadlineAllowedCategories?.includes(category) ?? true;

	// 	console.log({ topic });
	// 	console.log({ category, closed, solved, categoryIncluded });

	// 	if (!categoryIncluded) return;
	// 	if (!siteSettings.deadlineDisplayOnClosedTopic && closed) return;
	// 	if (!siteSettings.deadlineDisplayOnSolvedTopic && solved) return;
	// 	if (!topic.deadline_timestamp) return;

	// 	return null;
	// });
});
