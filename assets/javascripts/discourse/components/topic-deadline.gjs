import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import { getDeadlineRemainingDays } from "../../lib/get-deadline-remaining-days";
import { getDeadlineRemainingDaysClass } from "../../lib/get-deadline-remaining-days-class";
import { getSiteSettings } from "../../lib/get-site-settings";
import { translateDeadlineRemainingDays } from "../../lib/translate-deadline-remaining-days";

export class TopicDeadline extends Component {
    #settings = null;

    get settings() {
        if (this.#settings === null) {
            this.#settings = withPluginApi("1.34", (api) => getSiteSettings(api));
        }
        return this.#settings;
    }

    get topic() {
        return this.args.topic;
    }

    get shouldRender() {
        const settings = this.settings;
        const category = this.topic.category_id;
        const closed = this.topic.closed;
        const solved = this.topic.has_accepted_answer === true;
        const categoryIncluded =
            this.deadlineAllowedCategories?.includes(category) ?? true;

        if (!categoryIncluded) return false;
        if (!settings.deadlineDisplayOnClosedTopic && closed) return false;
        if (!settings.deadlineDisplayOnSolvedTopic && solved) return false;

        return true;
    }

    get content() {
        console.log(this.topic);
        const settings = this.settings;
        console.log(settings);
        // const timestamp = Number.parseInt(settings.deadline_timestamp, 10);
        // const deadlineDate = new Date(timestamp);
        // const formattedDate = deadlineDate.toLocaleDateString("cs-CZ", {
        //     year: "numeric",
        //     month: "long",
        //     day: "numeric",
        // });
        // return formattedDate;
        return 'XXX';
    }

    <template>
        {{#if this.shouldRender}}
            <span>{{this.content}}</span>
        {{/if}}
    </template>
}