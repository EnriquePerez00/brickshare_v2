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
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Loader2, Edit2, AlertCircle, ClipboardList } from "lucide-react";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/contexts/AuthContext";

interface ReturnItem {
    id: string;
    user_id: string;
    set_id: string;
    created_at: string;
    shipment_status: string;
    users: {
        full_name: string | null;
        email: string | null;
    };
    sets: {
        id: string;
        set_ref: string | null;
        set_name: string;
        set_weight: number | null;
        set_status: string | null;
    } | null;
}

const ReturnsList = () => {
    const [returns, setReturns] = useState<ReturnItem[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [isDialogOpen, setIsDialogOpen] = useState(false);
    const [selectedItem, setSelectedItem] = useState<ReturnItem | null>(null);
    const [newStatus, setNewStatus] = useState<string>("");
    const [isUpdating, setIsUpdating] = useState(false);
    const { toast } = useToast();
    const { user } = useAuth();

    const fetchReturns = async () => {
        setIsLoading(true);
        try {
            const { data, error } = await supabase
                .from("shipments" as any)
                .select(`
                    id,
                    user_id,
                    created_at,
                    shipment_status,
                    set_id,
                    users (
                        full_name,
                        email
                    ),
                    sets (
                        id,
                        set_ref,
                        set_name,
                        set_weight,
                        set_status
                    )
                `)
                .eq("shipment_status", "returned")
                .eq("handling_processed", false)
                .order("created_at", { ascending: false });

            if (error) throw error;
            setReturns(data as any);
        } catch (error: any) {
            console.error("Error fetching returns:", error);
            toast({
                title: "Error loading returns",
                description: `Error: ${error.message || error.code || JSON.stringify(error)}`,
                variant: "destructive",
            });
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        fetchReturns();
    }, []);

    const handleEditClick = (item: ReturnItem) => {
        setSelectedItem(item);
        setNewStatus(item.sets?.set_status || "inactive");
        setIsDialogOpen(true);
    };

    const handleConfirmUpdate = async () => {
        if (!selectedItem || !selectedItem.sets) return;

        setIsUpdating(true);
        try {
            const { error } = await supabase.rpc("update_set_status_from_return", {
                p_set_id: selectedItem.sets.id,
                p_new_status: newStatus,
                p_envio_id: selectedItem.id
            });

            if (error) throw error;

            toast({
                title: "Status updated",
                description: `The set status has been changed to "${newStatus}".`,
                className: "bg-green-100 border-green-200 dark:bg-green-900/30 dark:border-green-800",
            });

            await fetchReturns();
            setIsDialogOpen(false);
        } catch (error: any) {
            console.error("Error updating status:", error);
            toast({
                title: "Error",
                description: error.message || "Could not update status.",
                variant: "destructive",
            });
        } finally {
            setIsUpdating(false);
        }
    };

    const getStatusBadgeVariant = (status: string) => {
        switch (status) {
            case "active": return "default";
            case "inactive": return "secondary";
            case "in_repair": return "destructive";
            default: return "outline";
        }
    };

    if (isLoading) {
        return (
            <div className="flex justify-center p-8">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    if (returns.length === 0) {
        return (
            <div className="text-center p-8 bg-muted/20 rounded-xl border border-dashed border-muted-foreground/30">
                <ClipboardList className="h-12 w-12 mx-auto text-muted-foreground mb-3 opacity-50" />
                <h3 className="text-lg font-medium text-foreground">No pending returns</h3>
                <p className="text-muted-foreground">No shipments found in 'returned' status.</p>
                <Button variant="ghost" size="sm" onClick={fetchReturns} className="mt-4">
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
                            <TableHead>Date</TableHead>
                            <TableHead>User</TableHead>
                            <TableHead>Set Ref</TableHead>
                            <TableHead>Reference Weight</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {returns.map((item) => (
                            <TableRow key={item.id}>
                                <TableCell>
                                    {new Date(item.created_at).toLocaleDateString()}
                                </TableCell>
                                <TableCell>
                                    <div className="flex flex-col">
                                        <span className="font-medium">{item.users?.full_name || "No name"}</span>
                                        <span className="text-xs text-muted-foreground">{item.users?.email}</span>
                                    </div>
                                </TableCell>
                                <TableCell>
                                    <div className="flex items-center gap-2">
                                        <span className="font-mono font-bold bg-muted px-2 py-1 rounded">
                                            {item.sets?.set_ref || "N/A"}
                                        </span>
                                        <span className="text-xs text-muted-foreground truncate max-w-[150px]">
                                            {item.sets?.set_name}
                                        </span>
                                    </div>
                                </TableCell>
                                <TableCell>
                                    <div className="flex items-center gap-1 font-mono text-sm">
                                        <span>{item.sets?.set_weight ? `${item.sets.set_weight}g` : "N/A"}</span>
                                    </div>
                                </TableCell>
                                <TableCell className="text-right">
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        onClick={() => handleEditClick(item)}
                                        title="Edit set status"
                                    >
                                        <Edit2 className="h-4 w-4" />
                                    </Button>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </div>

            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Update Set Status</DialogTitle>
                        <DialogDescription>
                            Change the status of set <strong>{selectedItem?.sets?.set_ref}</strong>.
                            This action will automatically update the inventory.
                        </DialogDescription>
                    </DialogHeader>

                    <div className="grid gap-4 py-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                                Test Result
                            </label>
                            <Select value={newStatus} onValueChange={setNewStatus}>
                                <SelectTrigger>
                                    <SelectValue placeholder="Select test result" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="active">Weight OK (Move to Stock)</SelectItem>
                                    <SelectItem value="in_repair">Missing Pieces (Move to Repair)</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>

                        {newStatus === "in_repair" && (
                            <div className="bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-900 rounded-lg p-3 flex gap-3 text-amber-800 dark:text-amber-200 text-sm">
                                <AlertCircle className="h-5 w-5 flex-shrink-0" />
                                <p>Will be marked as "In Repair" (+1 unit).</p>
                            </div>
                        )}

                        {newStatus === "active" && (
                            <div className="bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-900 rounded-lg p-3 flex gap-3 text-blue-800 dark:text-blue-200 text-sm">
                                <AlertCircle className="h-5 w-5 flex-shrink-0" />
                                <p>Will be marked as "Active/Stock".</p>
                            </div>
                        )}
                    </div>

                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsDialogOpen(false)} disabled={isUpdating}>
                            Cancel
                        </Button>
                        <Button onClick={handleConfirmUpdate} disabled={isUpdating}>
                            {isUpdating && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Confirm Change
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
};

export default ReturnsList;