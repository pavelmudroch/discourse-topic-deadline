import Component from "@glimmer/component";
import { tracked } from '@glimmer/tracking';
import { withPluginApi } from "discourse/lib/plugin-api";
import { getDeadlineRemainingDays } from "../../lib/get-deadline-remaining-days";
import { getDeadlineRemainingDaysClass } from "../../lib/get-deadline-remaining-days-class";
import { getSiteSettings } from "../../lib/get-site-settings";
import { translateDeadlineRemainingDays } from "../../lib/translate-deadline-remaining-days";

export class TopicDeadline extends Component {
    #settings = null;

    @tracked
    colorClass = '';

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
        if (!this.topic.deadline_timestamp) return false;

        return true;
    }

    get content() {
        console.log(this.topic);
        console.log(this.topic.deadline_timestamp);
        const settings = this.settings;
        console.log(settings);
        const rawDeadlineTimestamp = this.topic.deadline_timestamp ?? '0';
        const deadlineTimestamp = Number.parseInt(rawDeadlineTimestamp, 10);
        const deadlineDate = new Date(deadlineTimestamp);
        const formattedDeadlineDate = deadlineDate.toLocaleDateString("cs-CZ", {
            year: "numeric",
            month: "long",
            day: "numeric",
        });
        const deadlineRemainingDays = getDeadlineRemainingDays(deadlineTimestamp);
        this.colorClass = getDeadlineRemainingDaysClass(
            deadlineRemainingDays,
            settings.deadlineSoonDaysThreshold,
        );
        const deadlineDayFormatted = translateDeadlineRemainingDays(deadlineRemainingDays);
        const content = [];
        if (deadlineDayFormatted !== null) {
            content.push(deadlineDayFormatted);
        }
        content.push(formattedDeadlineDate);

        return content.join(' - ');
    }

    <template>
        {{#if this.shouldRender}}
            <span class='{{this.colorClass}} topic-deadline-date'>{{this.content}}</span>
        {{/if}}
    </template>
}