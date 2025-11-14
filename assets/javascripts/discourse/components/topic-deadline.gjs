import Component from "@glimmer/component";
import { tracked } from '@glimmer/tracking';
import { withPluginApi } from "discourse/lib/plugin-api";
import { getDeadlineRemainingDays } from "../../lib/get-deadline-remaining-days";
import { getDeadlineRemainingDaysClass } from "../../lib/get-deadline-remaining-days-class";
import { getSiteSettings } from "../../lib/get-site-settings";
import { translateDeadlineRemainingDays } from "../../lib/translate-deadline-remaining-days";

export class TopicDeadline extends Component {
    #settings = null;

    get deadlineClass() {
        const classes = ['topic-deadline-date'];
        
        const rawDeadlineTimestamp = this.topic.deadline_timestamp ?? '0';
        const deadlineTimestamp = Number.parseInt(rawDeadlineTimestamp, 10);
        const settings = this.settings;
        const deadlineRemainingDays = getDeadlineRemainingDays(deadlineTimestamp);
        const colorClass = getDeadlineRemainingDaysClass(
            deadlineRemainingDays,
            settings.deadlineSoonDaysThreshold,
        );
        classes.push(colorClass);

        if (this.topic.closed) {
            classes.push('topic-closed-deadline');
        }

        return classes.join(' ');
    }

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
        const settings = this.settings;
        const rawDeadlineTimestamp = this.topic.deadline_timestamp ?? '0';
        const deadlineTimestamp = Number.parseInt(rawDeadlineTimestamp, 10);
        const deadlineDate = new Date(deadlineTimestamp);
        const formattedDeadlineDate = deadlineDate.toLocaleDateString("cs-CZ", {
            year: "numeric",
            month: "long",
            day: "numeric",
        });
        const deadlineRemainingDays = getDeadlineRemainingDays(deadlineTimestamp);
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
            <span class={{this.deadlineClass}}>
                <svg style="fill: currentColor;" class="d-icon svg-icon"><use href="#far-clock"></use></svg>
                <span>{{this.content}}</span>
            </span>
        {{/if}}
    </template>
}