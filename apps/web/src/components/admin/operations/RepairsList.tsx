import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Loader2, AlertTriangle, ClipboardList } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import MissingPiecesDialog from "./MissingPiecesDialog";

interface RepairItem {
    id: string;
    set_ref: string | null;
    set_name: string;
    set_status: string;
}

const RepairsList = () => {
    const [repairs, setRepairs] = useState<RepairItem[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [selectedSetId, setSelectedSetId] = useState<string | null>(null);
    const [selectedSetRef, setSelectedSetRef] = useState<string>("");
    const [isMissingPiecesDialogOpen, setIsMissingPiecesDialogOpen] =
        useState(false);
    const { toast } = useToast();

    const fetchRepairs = async () => {
        setIsLoading(true);
        try {
            const { data, error } = await supabase
                .from("sets")
                .select("id, set_ref, set_name, set_status")
                .eq("set_status", "in_repair")
                .order("set_ref", { ascending: true });

            if (error) throw error;
            setRepairs(data as any);
        } catch (error: any) {
            console.error("Error fetching repairs:", error);
            toast({
                title: "Error loading repairs",
                description: `Error: ${error.message || error.code || JSON.stringify(error)}`,
                variant: "destructive",
            });
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        fetchRepairs();
    }, []);

    const handleMissingPiecesClick = (setId: string, setRef: string) => {
        setSelectedSetId(setId);
        setSelectedSetRef(setRef);
        setIsMissingPiecesDialogOpen(true);
    };

    const handleMissingPiecesDialogClose = (open: boolean) => {
        setIsMissingPiecesDialogOpen(open);
        if (!open) {
            setSelectedSetId(null);
            setSelectedSetRef("");
            // Refresh the list after dialog closes (in case pieces were added)
            fetchRepairs();
        }
    };

    if (isLoading) {
        return (
            <div className="flex justify-center p-8">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    if (repairs.length === 0) {
        return (
            <div className="text-center p-8 bg-muted/20 rounded-xl border border-dashed border-muted-foreground/30">
                <ClipboardList className="h-12 w-12 mx-auto text-muted-foreground mb-3 opacity-50" />
                <h3 className="text-lg font-medium text-foreground">No sets in repair</h3>
                <p className="text-muted-foreground">All sets are in good condition.</p>
                <Button variant="ghost" size="sm" onClick={fetchRepairs} className="mt-4">
                    Refresh
                </Button>
            </div>
        );
    }

    return (
        <div className="space-y-4">
            <div className="rounded-md border">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Set Ref</TableHead>
                            <TableHead>Set Name</TableHead>
                            <TableHead>Status</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {repairs.map((item) => (
                            <TableRow key={item.id}>
                                <TableCell>
                                    <span className="font-mono font-bold bg-muted px-2 py-1 rounded">
                                        {item.set_ref || "N/A"}
                                    </span>
                                </TableCell>
                                <TableCell>
                                    <span className="text-sm">{item.set_name}</span>
                                </TableCell>
                                <TableCell>
                                    <div className="flex items-center gap-2">
                                        <AlertTriangle className="h-4 w-4 text-orange-500" />
                                        <span className="text-xs font-medium uppercase tracking-wide">
                                            In Repair
                                        </span>
                                    </div>
                                </TableCell>
                                <TableCell className="text-right">
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() =>
                                            handleMissingPiecesClick(item.id, item.set_ref || "N/A")
                                        }
                                        title="Register missing pieces"
                                    >
                                        <AlertTriangle className="h-4 w-4 mr-2" />
                                        Missing Parts
                                    </Button>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </div>

            {selectedSetId && (
                <MissingPiecesDialog
                    open={isMissingPiecesDialogOpen}
                    onOpenChange={handleMissingPiecesDialogClose}
                    setId={selectedSetId}
                    setRef={selectedSetRef}
                />
            )}
        </div>
    );
};

export default RepairsList;