package org.matsim.run.prepare.myPrepare;

import org.matsim.api.core.v01.Id;
import org.matsim.api.core.v01.network.Network;
import org.matsim.application.MATSimAppCommand;
import org.matsim.core.network.NetworkUtils;
import picocli.CommandLine;

/**
 * @Autor:xinxin
 */
public class PrepareNetworkRemoveEuropaBrueckeLinkId implements MATSimAppCommand {
    @CommandLine.Command(name = "network", description = "close EuropaBruecke")
    @CommandLine.Option(names = "--network", description = "Path to network file", required = true)
    private String networkFile;
    @CommandLine.Option(names = "--output", description = "Output path of the prepared network", required = true)
    private String outputPath;

    public static void main(String[] args) {
        new PrepareNetworkRemoveEuropaBrueckeLinkId().execute(args);
    }
    @Override
    public Integer call() throws Exception {
        Network network = NetworkUtils.readNetwork(networkFile);
        network.removeLink(Id.createLinkId(23987639));
        network.removeLink(Id.createLinkId(-585581112));
        NetworkUtils.runNetworkCleaner(network);
        NetworkUtils.writeNetwork(network,outputPath);
        return 0;
    }
}
