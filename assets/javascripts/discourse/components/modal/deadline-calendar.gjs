import { action } from '@ember/object';
import { service } from '@ember/service';
import { isEmpty } from '@ember/utils';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import I18n, { i18n } from 'discourse-i18n';
import { ajax } from 'discourse/lib/ajax';
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DatePicker from "discourse/components/date-picker";

export default class SetDeadline extends Component {
    @service siteSettings;
    @service appEvents;
    @tracked saving = false;
    @tracked date = moment().format('YYYY-MM-DD');
    @tracked flash;
    hasDeadline;
    #time = '23:59';

    <template>
        <DModal
            @bodyClass='change-timestamp'
            @closeModal={{@closeModal}}
            @flash={{this.flash}}
            @title={{i18n 'deadline.calendar.title'}}
        >
            <:body>
                <p>
                    {{i18n 'deadline.calendar.instructions'}}
                </p>
                <p class='alert alert-error {{unless this.validTimestamp "hidden"}}'>
                    {{i18n 'deadline.calendar.invalid_date'}}
                </p>
                <form>
                    <DatePicker
                        @value={{readonly this.date}}
                        @containerId='date-container'
                        @onSelect={{action (mut this.date)}}
                    />
                </form>
                <div id='date-container'></div>
            </:body>
            <:footer>
                <DButton
                    class='btn-primary'
                    @disabled={{this.buttonDisabled}}
                    @action={{this.setDeadline}}
                    @label={{if
                        this.saving
                        'deadline.calendar.saving'
                        'deadline.calendar.action'
                    }}
                />
                {{#if this.hasDeadline}}
                    <DButton
                        class='btn-danger'
                        @action={{this.removeDeadline}}
                        @label={{'deadline.calendar.cancel'}}
                    />
                {{/if}}
            </:footer>
            </DModal>
    </template>

    constructor() {
        super(...arguments);
        const topic = this.args.model;
        const deadline = topic.deadline_timestamp;
        this.hasDeadline = deadline !== null && deadline !== '';

        if (deadline) this.#setCurrentDateTimeFromDeadline(deadline);
    }

    get createdAt() {
        return moment(`${this.date} ${this.#time}`, 'YYYY-MM-DD HH:mm');
    }

    get validTimestamp() {
        return moment().diff(this.createdAt, 'minutes') > 0;
    }

    get buttonDisabled() {
        return this.saving || this.validTimestamp || isEmpty(this.date);
    }

    @action
    async setDeadline() {
        const topic = this.args.model;
        const datetime = new Date(`${this.date} ${this.#time}`).valueOf();

        this.saving = true;
        try {
            await ajax(`/discourse-topic-deadline/topics/${topic.id}`, {
                type: 'PUT',
                data: {
                    custom_fields: {
                        deadline_timestamp: datetime,
                    },
                },
            });
            this.appEvents.trigger('deadline:changed');
            this.args.closeModal();
        } catch (error) {
            console.error(error);
            this.flash = I18n.t('deadline.calendar.action_error');
        } finally {
            this.saving = false;
        }
    }

    @action
    async removeDeadline() {
        const topic = this.args.model;
        const datetime = null;

        this.saving = true;
        try {
            await ajax(`/discourse-topic-deadline/topics/${topic.id}`, {
                type: 'PUT',
                data: {
                    custom_fields: {
                        deadline_timestamp: datetime,
                    },
                },
            });
            this.appEvents.trigger('deadline:changed');
            this.args.closeModal();
        } catch (error) {
            console.error(error);
            this.flash = I18n.t('deadline.calendar.action_error');
        } finally {
            this.saving = false;
        }
    }

    #setCurrentDateTimeFromDeadline(deadline) {
        const date = new Date(parseInt(deadline));
        this.date = date.toLocaleDateString('en-CA');
        // this.#time = date.toLocaleTimeString('cs-CZ', {
        //     hour12: false,
        //     hourCycle: 'h23',
        //     minute: '2-digit',
        //     hour: '2-digit',
        // });
    }
}
