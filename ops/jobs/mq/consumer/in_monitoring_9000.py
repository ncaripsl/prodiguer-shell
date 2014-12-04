# -*- coding: utf-8 -*-

"""
.. module:: run_in_monitoring_9000.py
   :copyright: Copyright "Apr 26, 2013", Institute Pierre Simon Laplace
   :license: GPL/CeCIL
   :platform: Unix
   :synopsis: Consumes monitoring 9000 messages.

.. moduleauthor:: Mark Conway-Greenslade <momipsl@ipsl.jussieu.fr>


"""
from prodiguer import db, mq

import in_monitoring_utils as utils



# MQ exhange to bind to.
MQ_EXCHANGE = mq.constants.EXCHANGE_PRODIGUER_IN

# MQ queue to bind to.
MQ_QUEUE = mq.constants.QUEUE_IN_MONITORING_9000


def get_tasks():
    """Returns set of tasks to be executed when processing a message.

    """
    return (
        _unpack_message,
        _persist_simulation_state,
        _notify_api,
        _notify_operator
        )


# Message information wrapper.
class Message(mq.Message):
    """Message information wrapper.

    """
    def __init__(self, props, body, decode=True):
        """Object constructor.

        """
        super(Message, self).__init__(props, body, decode=decode)

        self.simulation = None
        self.simulation_uid = None
        self.execution_state_timestamp = None


def _unpack_message(ctx):
    """Unpacks message being processed.

    """
    ctx.simulation_uid = ctx.content['simuid']
    ctx.execution_state_timestamp = utils.get_timestamp(ctx.props.headers['timestamp'])


def _persist_simulation_state(ctx):
    """Persists simulation state to db.

    """
    mq.db_hooks.create_simulation_state(
        ctx.simulation_uid,
        db.constants.EXECUTION_STATE_ROLLBACK,
        ctx.execution_state_timestamp,
        MQ_QUEUE
        )


def _notify_api(ctx):
    """Dispatches API notification.

    """
    utils.notify_api_of_simulation_state_change(
        ctx.simulation_uid, db.constants.EXECUTION_STATE_ROLLBACK)


def _notify_operator(ctx):
    """Dispatches operator notification.

    """
    utils.notify_operator(ctx.simulation_uid, "monitoring-9000")
