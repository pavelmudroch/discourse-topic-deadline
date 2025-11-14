import Component from "@glimmer/component";

export class TopicDeadline extends Component {
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
        const category = this.topic.category_id;
        const closed = this.topic.closed;
        const solved = this.topic.has_accepted_answer === true;
        const categoryIncluded =
            this.deadlineAllowedCategories?.includes(category) ?? true;

        console.log({
            category,
            closed,
            solved,
            categoryIncluded,
            deadlineDisplayOnClosedTopic: this.deadlineDisplayOnClosedTopic,
            deadlineDisplayOnSolvedTopic: this.deadlineDisplayOnSolvedTopic,
            deadline_timestamp: this.topic.deadline_timestamp,
            deadlineAllowedCategories: this.deadlineAllowedCategories,
        });

        if (!categoryIncluded) return false;
        if (!this.deadlineDisplayOnClosedTopic && closed) return false;
        if (!this.deadlineDisplayOnSolvedTopic && solved) return false;
        if (!this.topic.deadline_timestamp) return false;

        return true;
    }

    <template>
        {{#if this.shouldRender}}
            XXX
        {{/if}}
    </template>
}