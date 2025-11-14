import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import { getDeadlineRemainingDays } from "../../lib/get-deadline-remaining-days";
import { getDeadlineRemainingDaysClass } from "../../lib/get-deadline-remaining-days-class";
import { getSiteSettings } from "../../lib/get-site-settings";
import { translateDeadlineRemainingDays } from "../../lib/translate-deadline-remaining-days";

export class TopicDeadline extends Component {
    get settings() {
        return withPluginApi("1.34", (api) => getSiteSettings(api));
    }

    get topic() {
        return this.args.topic;
    }

    get deadlineDisplayOnClosedTopic() {
        return this.args.deadlineDisplayOnClosedTopic;
    }

    get deadlineDisplayOnSolvedTopic() {
        return this.args.deadlineDisplayOnSolvedTopic;
    }

    get deadlineAllowedCategories() {
        return this.args.deadlineAllowedCategories;
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
        if (!settings.topic.deadline_timestamp) return false;

        return true;
    }

    get content() {
        const settings = this.settings;
        const timestamp = Number.parseInt(this.topic.deadline_timestamp, 10);
        const deadlineDate = new Date(timestamp);
        const formattedDate = deadlineDate.toLocaleDateString("cs-CZ", {
            year: "numeric",
            month: "long",
            day: "numeric",
        });

        const remainingDays = getDeadlineRemainingDays(timestamp);
        const colorClass = getDeadlineRemainingDaysClass(
            remainingDays,
            settings.deadlineSoonDaysThreshold,
        );
        const formattedRemainingDays = translateDeadlineRemainingDays(remainingDays);

        const content = `${formattedRemainingDays?.concat(" - ") ?? ""}${formattedDate}`;
        const svg = '<svg style="fill: currentColor;" class="d-icon svg-icon"><use href="#far-clock"></use></svg>';
        return `<span class="topic-deadline-date ${colorClass}">${svg}${content}</span>`;
    }

    <template>
        {{#if this.shouldRender}}
            <span>{{this.content}}</span>
        {{/if}}
    </template>
}