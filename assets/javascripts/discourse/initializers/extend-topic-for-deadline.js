import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.34", (api) => {
	api.renderInOutlet("after-topic-list-item", (outletArgs) => {
		const topic = outletArgs.topic;

		const category = topic.category_id;
		const closed = topic.closed;
		const solved = topic.has_accepted_answer === true;
		const categoryIncluded =
			siteSettings.deadlineAllowedCategories?.includes(category) ?? true;

		console.log({ topic });
		console.log({ category, closed, solved, categoryIncluded });

		if (!categoryIncluded) return;
		if (!siteSettings.deadlineDisplayOnClosedTopic && closed) return;
		if (!siteSettings.deadlineDisplayOnSolvedTopic && solved) return;
		if (!topic.deadline_timestamp) return;

		return null;
	});
});
