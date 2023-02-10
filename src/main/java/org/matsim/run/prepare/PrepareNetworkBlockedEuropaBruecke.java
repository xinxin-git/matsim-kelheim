package org.matsim.run.prepare;

import org.matsim.api.core.v01.Id;
import org.matsim.api.core.v01.network.Network;
import org.matsim.application.MATSimAppCommand;
import org.matsim.core.network.NetworkUtils;
import picocli.CommandLine;

/**
 * @Autor:xinxin
 */
public class PrepareNetworkBlockedEuropaBruecke implements MATSimAppCommand {
    @CommandLine.Command(name = "network", description = "close EuropaBruecke")
    @CommandLine.Option(names = "--network", description = "Path to network file", required = true)
    private String networkFile;
    @CommandLine.Option(names = "--output", description = "Output path of the prepared network", required = true)
    private String outputPath;

    public static void main(String[] args) {
        new PrepareNetworkBlockedEuropaBruecke().execute(args);
    }
    @Override
    public Integer call() throws Exception {
        Network network = NetworkUtils.readNetwork(networkFile);

        network.getLinks().get(Id.createLinkId("23987639")).setFreespeed(0.01);
        network.getLinks().get(Id.createLinkId("-585581112")).setFreespeed(0.01);
        network.getLinks().get(Id.createLinkId("23987640")).setFreespeed(0.01);
        network.getLinks().get(Id.createLinkId("-23987640")).setFreespeed(0.01);

        network.getLinks().get(Id.createLinkId("23987639")).setCapacity(10.);
        network.getLinks().get(Id.createLinkId("-585581112")).setCapacity(10.);
        network.getLinks().get(Id.createLinkId("23987640")).setCapacity(10.);
        network.getLinks().get(Id.createLinkId("-23987640")).setCapacity(10.);
//        NetworkUtils.runNetworkCleaner(network);
        NetworkUtils.writeNetwork(network,outputPath);
        return 0;
    }
}
