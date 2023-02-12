package org.matsim.analysis.myAnalysis;

import org.matsim.api.core.v01.events.LinkEnterEvent;
import org.matsim.api.core.v01.events.handler.LinkEnterEventHandler;
import org.matsim.api.core.v01.network.Network;

import java.util.Map;

/**
 * @Autor:xinxin
 */
public class RoadEventHandler implements LinkEnterEventHandler {
    private final Map<String, Integer> blockedLinkCount;

    RoadEventHandler(Map<String, Integer> blockedLinkCount) {
        this.blockedLinkCount = blockedLinkCount;
    }

    @Override
    public void handleEvent(LinkEnterEvent linkEnterEvent) {
        if (blockedLinkCount.containsKey(linkEnterEvent.getLinkId().toString())) {
            blockedLinkCount.replace(linkEnterEvent.getLinkId().toString(),
                    blockedLinkCount.get(linkEnterEvent.getLinkId().toString()) + 1);
        }
    }
}
