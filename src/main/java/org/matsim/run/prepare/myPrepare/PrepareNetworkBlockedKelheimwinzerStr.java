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
public class PrepareNetworkBlockedKelheimwinzerStr implements MATSimAppCommand {
    @CommandLine.Command(name = "network", description = "close RegensburgerStrasse")
    @CommandLine.Option(names = "--network", description = "Path to network file", required = true)
    private String networkFile;
    @CommandLine.Option(names = "--output", description = "Output path of the prepared network", required = true)
    private String outputPath;
    public static void main(String[] args) {
        new PrepareNetworkBlockedKelheimwinzerStr().execute(args);
    }
    @Override
    public Integer call() throws Exception {
        Network network = NetworkUtils.readNetwork(networkFile);
        List<String> blockedLinks = Arrays.asList("-27089112#6","27089112#5","-27089112#4","27089112#4","-27089112#3","27089112#3",
                "-27089112#2","27089112#2","-27089112#1","27089112#1","-27089112#0","27089112#0","-485539146#6","485539146#6","-485539146#5","485539146#5",
                "-485539146#3","485539146#3","-485539146#0","485539146#0");
        for (String linkId : blockedLinks) {
            network.getLinks().get(Id.createLinkId(linkId)).setFreespeed(0.01);
            network.getLinks().get(Id.createLinkId(linkId)).setCapacity(10.);
        }
        NetworkUtils.writeNetwork(network,outputPath);
        return 0;
    }
}
