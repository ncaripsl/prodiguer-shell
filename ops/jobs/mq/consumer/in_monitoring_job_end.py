# -*- coding: utf-8 -*-

"""
.. module:: in_monitoring_job_end.py
   :copyright: Copyright "Apr 26, 2013", Institute Pierre Simon Laplace
   :license: GPL/CeCIL
   :platform: Unix
   :synopsis: Consumes monitoring job end messages.

.. moduleauthor:: Mark Conway-Greenslade <momipsl@ipsl.jussieu.fr>


"""
from prodiguer import mq
from prodiguer.db import pgres as db

import utils



def get_tasks():
    """Returns set of tasks to be executed when processing a message.

    """
    return (
      _unpack_message_content,
      _persist_job_updates,
      _set_simulation,
      _notify_api
      )


class ProcessingContextInfo(mq.Message):
    """Message processing context information.

    """
    def __init__(self, props, body, decode=True):
        """Object constructor.

        """
        super(ProcessingContextInfo, self).__init__(
            props, body, decode=decode)

        self.job_uid = None
        self.simulation_uid = None


def _unpack_message_content(ctx):
    """Unpacks message being processed.

    """
    ctx.job_uid = ctx.content['jobuid']
    ctx.simulation_uid = ctx.content['simuid']


def _persist_job_updates(ctx):
    """Persists job updates to db.

    """
    db.dao_monitoring.persist_job_02(
        ctx.msg.timestamp,
        False,
        ctx.job_uid,
        ctx.simulation_uid
        )


def _set_simulation(ctx):
    """Sets simulation being processed.

    """
    ctx.simulation = db.dao_monitoring.retrieve_simulation(ctx.simulation_uid)


def _notify_api(ctx):
    """Dispatches API notification.

    """
    # Skip if simulation start message (0000) has not yet been received.
    if ctx.simulation is None:
        return
    # Skip if simulation is obsolete (i.e. it was restarted).
    if ctx.simulation.is_obsolete:
        return

    data = {
        "event_type": u"job_complete",
        "job_uid": unicode(ctx.job_uid),
        "simulation_uid": unicode(ctx.simulation_uid)
    }

    utils.dispatch_message(data, mq.constants.TYPE_GENERAL_API)