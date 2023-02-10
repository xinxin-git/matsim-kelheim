package org.matsim.analysis.myAnalysis;

import org.matsim.api.core.v01.events.LinkEnterEvent;
import org.matsim.api.core.v01.events.LinkLeaveEvent;
import org.matsim.api.core.v01.events.handler.LinkEnterEventHandler;
import org.matsim.api.core.v01.events.handler.LinkLeaveEventHandler;

import java.util.Map;

/**
 * @Autor:xinxin
 */
public class RoadEventTimeHandler implements LinkEnterEventHandler, LinkLeaveEventHandler {
    private final Map<String, Double> blockedLinkCount;

    public RoadEventTimeHandler(Map<String, Double> blockedLinkCount) {
        this.blockedLinkCount = blockedLinkCount;
    }

    @Override
    public void handleEvent(LinkEnterEvent linkEnterEvent) {
        if (blockedLinkCount.containsKey(linkEnterEvent.getLinkId().toString())) {
            blockedLinkCount.replace(linkEnterEvent.getLinkId().toString(), blockedLinkCount.get(linkEnterEvent.getLinkId().toString()) - linkEnterEvent.getTime());

        }
    }

    @Override
    public void handleEvent(LinkLeaveEvent linkLeaveEvent) {
        if (blockedLinkCount.containsKey(linkLeaveEvent.getLinkId().toString())) {
            blockedLinkCount.replace(linkLeaveEvent.getLinkId().toString(), blockedLinkCount.get(linkLeaveEvent.getLinkId().toString()) +linkLeaveEvent.getTime());

        }
    }
}
