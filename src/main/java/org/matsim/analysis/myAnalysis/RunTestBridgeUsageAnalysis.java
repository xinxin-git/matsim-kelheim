package org.matsim.analysis.myAnalysis;

import org.matsim.contrib.drt.util.DrtEventsReaders;
import org.matsim.core.api.experimental.events.EventsManager;
import org.matsim.core.events.EventsUtils;
import org.matsim.core.events.MatsimEventsReader;

/**
 * @Autor:xinxin
 */
public class RunTestBridgeUsageAnalysis {
    public static void main(String[] args) {
        TestBridgeEventHandler bridgeEventHandler = new TestBridgeEventHandler();
        EventsManager eventsManager = EventsUtils.createEventsManager();
        eventsManager.addHandler(bridgeEventHandler);
        MatsimEventsReader eventsReader = DrtEventsReaders.createEventsReader(eventsManager);
        eventsReader.readFile("D:\\Module\\oop\\matsim-kelheim\\scenarios\\output\\test-CORE\\kelheim-v2.0-25pct-av.output_events.xml.gz");
 //       eventsReader.readFile("D:\\Module\\oop\\matsim-kelheim\\scenarios\\output\\test-b2-freespeed-600-CORE\\kelheim-v2.0-25pct-av.output_events.xml.gz");
        System.out.println("BlockedBridgeCounterDirection1: "+bridgeEventHandler.getCounter1());
        System.out.println("BlockedBridgeCounterDirection2: "+bridgeEventHandler.getCounter2());
        System.out.println("TotalBlockedBridge: "+bridgeEventHandler.getTotalBlockBridge());
        System.out.println("AnotherBridgeCounterDirection1: "+bridgeEventHandler.getCounter3());
        System.out.println("AnotherBridgeCounterDirection2: "+bridgeEventHandler.getCounter4());
        System.out.println("TotalAnotherBridge: "+bridgeEventHandler.getTotalAnotherBridge());
        System.out.println("AnotherBridgeAverageTravelTimeDirection1: " + bridgeEventHandler.calculateAvgTravelTime1());
        System.out.println("AnotherBridgeAverageTravelTimeDirection2: " + bridgeEventHandler.calculateAvgTravelTime2());
    }
}
