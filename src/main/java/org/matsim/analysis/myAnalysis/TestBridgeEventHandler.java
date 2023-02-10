package org.matsim.analysis.myAnalysis;

import org.matsim.api.core.v01.events.LinkEnterEvent;
import org.matsim.api.core.v01.events.LinkLeaveEvent;
import org.matsim.api.core.v01.events.handler.LinkEnterEventHandler;
import org.matsim.api.core.v01.events.handler.LinkLeaveEventHandler;

/**
 * @Autor:xinxin
 */
public class TestBridgeEventHandler implements LinkEnterEventHandler, LinkLeaveEventHandler {
    private int counter1 =0;
    private int counter2 =0;
    private int counter3 =0;
    private int counter4 =0;
    private double travelTime1 = 0.0;
    private double travelTime2 = 0.0;
    @Override
    public void handleEvent(LinkEnterEvent linkEnterEvent) {
        if (linkEnterEvent.getLinkId().toString().equals("23987639")) {
            counter1++;
        }
        if (linkEnterEvent.getLinkId().toString().equals("-585581112")) {
            counter2++;
        }
        if (linkEnterEvent.getLinkId().toString().equals("8599673")) {
            counter3++;
            this.travelTime1 -= linkEnterEvent.getTime();
        }
        if (linkEnterEvent.getLinkId().toString().equals("-8599673")) {
            counter4++;
            this.travelTime2 -= linkEnterEvent.getTime();
        }
    }

    public int getCounter1() {
        return counter1;
    }

    public int getCounter2() {
        return counter2;
    }
    public int getTotalBlockBridge(){
        return counter1+counter2;
    }
    public int getCounter3() {
        return counter3;
    }
    public int getCounter4() {
        return counter4;
    }
    public int getTotalAnotherBridge(){
        return counter3+counter4;
    }

    @Override
    public void handleEvent(LinkLeaveEvent linkLeaveEvent) {
        if (linkLeaveEvent.getLinkId().toString().equals("8599673")) {
            this.travelTime1 += linkLeaveEvent.getTime();
        }
        if (linkLeaveEvent.getLinkId().toString().equals("-8599673")) {
            this.travelTime2 += linkLeaveEvent.getTime();
        }
    }

    public double calculateAvgTravelTime1(){
        return travelTime1/counter3;
    }
    public double calculateAvgTravelTime2(){
        return travelTime2/counter4;
    }
}
