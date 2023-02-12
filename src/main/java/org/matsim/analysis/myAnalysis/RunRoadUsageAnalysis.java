package org.matsim.analysis.myAnalysis;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.matsim.api.core.v01.network.Link;
import org.matsim.api.core.v01.network.Network;
import org.matsim.application.MATSimAppCommand;
import org.matsim.contrib.drt.util.DrtEventsReaders;
import org.matsim.core.api.experimental.events.EventsManager;
import org.matsim.core.events.EventsUtils;
import org.matsim.core.events.MatsimEventsReader;
import org.matsim.core.network.NetworkUtils;
import picocli.CommandLine;

import java.io.FileWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

/**
 * @Autor:xinxin
 */
public class RunRoadUsageAnalysis implements MATSimAppCommand {
    @CommandLine.Option(names = "--directory", description = "path to the directory of the simulation output", required = true)
    private Path directory;
    @CommandLine.Option(names = "--inputFile", description = "path to the directory of the simulation input EventFile", required = true)
    private String inputFile;
    @CommandLine.Option(names = "--inputNetwork", description = "Network of the simulation input", required = true)
    private String readNetwork;

    public static void main(String[] args) {
        new RunRoadUsageAnalysis().execute(args);
    }

    public Integer call() throws Exception {


        Network network = NetworkUtils.readNetwork(readNetwork);
        EventsManager eventsManager = EventsUtils.createEventsManager();

        Map<String, Integer> blockedLinkCount = new HashMap<>();
//        List<String> blockedLinks = Arrays.asList("23987639", "-585581112", "23987640", "-23987640");
//        List<String> blockedLinks = Arrays.asList("-27089112#6", "27089112#5", "-27089112#4", "27089112#4", "-27089112#3", "27089112#3",
//                "-27089112#2", "27089112#2", "-27089112#1", "27089112#1", "-27089112#0", "27089112#0", "-485539146#6", "485539146#6", "-485539146#5", "485539146#5",
//                "-485539146#3", "485539146#3", "-485539146#0", "485539146#0");
//        List<String> blockedLinks = Arrays.asList("827798494", "827798493", "-487456219#3", "487456219#3", "-487456219#2", "487456219#2", "-487456219#1", "487456219#1",
//                "-920868265", "920868265", "-487456219#0", "487456219#0", "-4712335#4", "4712335#4", "-492822158#0", "492822158#0", "-4712335#3", "4712335#3",
//                "-4712335#2", "4712335#2", "-4712335#1", "4712335#1", "-4712335#0", "4712335#0", "827847900", "827847899");
//        for (String linkId : blockedLinks) {
//            blockedLinkCount.put(linkId, 0);
//        }
        for (Link link : network.getLinks().values()) {
            if (link.getAllowedModes().contains("car")) {
                blockedLinkCount.put(link.getId().toString(), 0);
            }
        }

        RoadEventHandler roadEventHandler = new RoadEventHandler(blockedLinkCount);
        eventsManager.addHandler(roadEventHandler);

        MatsimEventsReader eventsReader = DrtEventsReaders.createEventsReader(eventsManager);
        eventsReader.readFile(inputFile);

        for (String s : blockedLinkCount.keySet()) {
            System.out.println("Link: " + s + " count: " + blockedLinkCount.get(s));
        }

//      write VehicleCount result
        Path outputFolder = Path.of(directory.toString() + "/analysis-road-usage");
        if (!Files.exists(outputFolder)) {
            Files.createDirectory(outputFolder);
        }
//      String vehicleRoadUsageFile = outputFolder + "/" + "allModes_vehicle_road_usage_withoutblocked.tsv";
        String vehicleRoadUsageFile = outputFolder + "/" + "allModes_vehicle_road_usage_withblocked.tsv";

        CSVPrinter vehicleRoadUsageWriter = new CSVPrinter(new FileWriter(vehicleRoadUsageFile), CSVFormat.TDF);
        List<String> header = new ArrayList<>();
        header.add("link_id");
        header.add("vehicleCount");
        vehicleRoadUsageWriter.printRecord(header);

        for (String linkId : blockedLinkCount.keySet()) {
            List<String> vehicleEntry = new ArrayList<>();
            vehicleEntry.add(linkId);
            vehicleEntry.add(blockedLinkCount.get(linkId).toString());
            vehicleRoadUsageWriter.printRecord(vehicleEntry);
        }
        vehicleRoadUsageWriter.close();
        return 0;
    }
}




