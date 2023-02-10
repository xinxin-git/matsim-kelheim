package org.matsim.run.prepare.myPrepare;

import org.matsim.api.core.v01.Id;
import org.matsim.api.core.v01.network.Network;
import org.matsim.application.MATSimAppCommand;
import org.matsim.core.network.NetworkUtils;
import picocli.CommandLine;

import java.util.Arrays;
import java.util.List;

/**
 * @Autor:xinxin
 */
public class PrepareNetworkBlockedRegensburgerStr implements MATSimAppCommand {
    @CommandLine.Command(name = "network", description = "close RegensburgerStrasse")
    @CommandLine.Option(names = "--network", description = "Path to network file", required = true)
    private String networkFile;
    @CommandLine.Option(names = "--output", description = "Output path of the prepared network", required = true)
    private String outputPath;

    public static void main(String[] args) {
        new PrepareNetworkBlockedRegensburgerStr().execute(args);
    }

    @Override
    public Integer call() throws Exception {
        Network network = NetworkUtils.readNetwork(networkFile);
        List<String> blockedLinks = Arrays.asList("827798494", "827798493", "-487456219#3", "487456219#3", "-487456219#2", "487456219#2", "-487456219#1", "487456219#1",
                "-920868265", "920868265", "-487456219#0", "487456219#0", "-4712335#4", "4712335#4", "-492822158#0", "492822158#0", "-4712335#3", "4712335#3",
                "-4712335#2", "4712335#2", "-4712335#1", "4712335#1", "-4712335#0", "4712335#0", "827847900", "827847899");
        for (String linkId : blockedLinks) {
            network.getLinks().get(Id.createLinkId(linkId)).setFreespeed(0.01);
            network.getLinks().get(Id.createLinkId(linkId)).setCapacity(10.);
        }
        NetworkUtils.writeNetwork(network, outputPath);
        return 0;
    }


}
