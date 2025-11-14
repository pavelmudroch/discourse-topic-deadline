import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.34", (api) => {
	api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
		console.log("[deadline-plugin] Transformer registered");

		return columns;
	});
});
