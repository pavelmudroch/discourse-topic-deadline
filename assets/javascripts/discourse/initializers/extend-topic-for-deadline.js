import I18n from 'I18n';
import { withPluginApi } from 'discourse/lib/plugin-api';
import PostCooked from 'discourse/widgets/post-cooked';
import DeadlineCalendar from '../components/modal/deadline-calendar';
import { getOwner } from '@ember/application';
import {
    getDeadlineRemainingDays,
    getDeadlineColorClassByRemainingDays,
    getDeadlineContent,
} from '../../lib/deadline-functions';

async function showSetDeadlineModal() {
    const model = this.model;
    const modal = getOwner(this).lookup('service:modal');
    modal.show(DeadlineCalendar, {
        model,
    });
}

function addSetDeadlineButton(api) {
    api.attachWidgetAction('post', 'setDeadline', showSetDeadlineModal);
    api.addPostMenuButton('deadline', (attrs) => {
        if (attrs.post_number !== 1) return;

        return {
            action: 'setDeadline',
            icon: 'calendar-alt',
            className: 'set-deadline create',
            title: 'deadline.set_button_title',
            position: 'first',
            label: 'deadline.set_button_label',
        };
    });
}

function isToEndOfTheDay(date) {
    const time = date.toLocaleTimeString('cs-CZ', {
        hour12: false,
        hourCycle: 'h23',
        minute: '2-digit',
        hour: '2-digit',
    });
    if (time !== '23:59') return false;

    return true;
}

function addPostDeadlineExcerpt(api) {
    api.decorateWidget('post-contents:before', (helper) => {
        if (helper.attrs.post_number === 1) {
            const postModel = helper.getModel();
            if (!postModel) return;

            const topic = postModel.topic;
            if (!topic.deadline_timestamp) return;

            const timestamp = parseInt(topic.deadline_timestamp);
            const deadlineRemainingDays = getDeadlineRemainingDays(timestamp);
            const deadlineColorClass = getDeadlineColorClassByRemainingDays(
                deadlineRemainingDays,
            );
            const closedTopicClass = topic.closed
                ? 'topic-closed-deadline'
                : '';

            const deadlineDate = new Date(timestamp);
            const showDeadlineTime =
                !isToEndOfTheDay(deadlineDate) && deadlineRemainingDays === 0;
            const deadlineExcerpt = `
                <div class='topic-deadline code ${deadlineColorClass} ${closedTopicClass}' data-topic='${
                topic.id
            }' title="${I18n.t('deadline.notifications.title')}">
                    <svg>
                        <use href='#calendar-alt'></use>
                    </svg>
                    <span class="deadline-date">${
                        getDeadlineContent(deadlineDate)?.concat(' - ') ?? ''
                    }${deadlineDate.toLocaleDateString('cs-CZ', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
            })}</span>${
                !showDeadlineTime
                    ? ''
                    : `<span class="deadline-time">${deadlineDate.toLocaleTimeString(
                          'cs-CZ',
                          {
                              hour12: false,
                              hourCycle: 'h23',
                              minute: '2-digit',
                              hour: '2-digit',
                          },
                      )}</span>`
            }
                </div>
            `;
            const cooked = new PostCooked({
                cooked: deadlineExcerpt,
            });
            return helper.rawHtml(cooked.init());
        }
    });
}

export default {
    name: 'extend-for-set-deadline-button',
    initialize() {
        withPluginApi('1.0.0', addPostDeadlineExcerpt);
        withPluginApi('1.0.0', addSetDeadlineButton);
    },
};