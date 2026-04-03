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
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Alert, AlertDescription } from "@/components/ui/alert";
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

const WEIGHT_TOLERANCE = 0.05; // 5%

const ReturnsList = () => {
    const [returns, setReturns] = useState<ReturnItem[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [isDialogOpen, setIsDialogOpen] = useState(false);
    const [selectedItem, setSelectedItem] = useState<ReturnItem | null>(null);
    const [measuredWeight, setMeasuredWeight] = useState<string>("");
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
        setMeasuredWeight("");
        setIsDialogOpen(true);
    };

    const calculateWeightValidation = (measured: number, expected: number | null) => {
        if (!expected || measured <= 0) return null;
        
        const minWeight = expected * (1 - WEIGHT_TOLERANCE);
        const maxWeight = expected * (1 + WEIGHT_TOLERANCE);
        const isOk = measured >= minWeight && measured <= maxWeight;
        const difference = measured - expected;

        return {
            isOk,
            minWeight: Math.round(minWeight * 100) / 100,
            maxWeight: Math.round(maxWeight * 100) / 100,
            difference: Math.round(difference * 100) / 100,
            status: isOk ? "active" : "in_repair",
        };
    };

    const handleConfirmUpdate = async () => {
        if (!selectedItem || !selectedItem.sets || !measuredWeight) return;

        const weight = parseFloat(measuredWeight);
        if (isNaN(weight) || weight <= 0) {
            toast({
                title: "Invalid weight",
                description: "Please enter a valid weight greater than 0.",
                variant: "destructive",
            });
            return;
        }

        setIsUpdating(true);
        try {
            // Call RPC function to process return with weight
            const { data, error } = await supabase.rpc(
                "process_set_return_with_weight",
                {
                    p_shipment_id: selectedItem.id,
                    p_set_id: selectedItem.set_id,
                    p_user_id: selectedItem.user_id,
                    p_weight_measured: weight,
                    p_weight_tolerance: WEIGHT_TOLERANCE,
                }
            );

            if (error) throw error;

            const result = data as any;
            if (!result.success) {
                throw new Error(result.error || "Unknown error");
            }

            toast({
                title: "Return processed successfully",
                description: `Set marked as ${result.new_status}. Weight: ${weight}g`,
                className: "bg-green-100 border-green-200 dark:bg-green-900/30 dark:border-green-800",
            });

            await fetchReturns();
            setIsDialogOpen(false);
        } catch (error: any) {
            console.error("Error processing return:", error);
            toast({
                title: "Error",
                description: error.message || "Could not process return.",
                variant: "destructive",
            });
        } finally {
            setIsUpdating(false);
        }
    };

    const validation = selectedItem?.sets?.set_weight && measuredWeight
        ? calculateWeightValidation(parseFloat(measuredWeight), selectedItem.sets.set_weight)
        : null;

    const isConfirmDisabled = !measuredWeight || isUpdating || !validation;

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
                                        title="Weigh and process return"
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
                        <DialogTitle>Process Set Return</DialogTitle>
                        <DialogDescription>
                            Weigh the set <strong>{selectedItem?.sets?.set_ref}</strong> and verify its condition.
                            Status will be automatically determined based on weight tolerance (±5%).
                        </DialogDescription>
                    </DialogHeader>

                    <div className="grid gap-4 py-4">
                        {/* Expected Weight Display */}
                        <div className="space-y-2 p-3 bg-muted rounded-lg">
                            <label className="text-sm font-medium text-muted-foreground">
                                Expected Weight
                            </label>
                            <div className="text-2xl font-bold">
                                {selectedItem?.sets?.set_weight ? `${selectedItem.sets.set_weight}g` : "N/A"}
                            </div>
                            {validation && (
                                <div className="text-xs text-muted-foreground">
                                    Acceptable range: {validation.minWeight}g - {validation.maxWeight}g
                                </div>
                            )}
                        </div>

                        {/* Measured Weight Input */}
                        <div className="space-y-2">
                            <Label htmlFor="weight">Measured Weight (gr)</Label>
                            <Input
                                id="weight"
                                type="number"
                                step="0.01"
                                min="0"
                                placeholder="000.00"
                                value={measuredWeight}
                                onChange={(e) => setMeasuredWeight(e.target.value)}
                                disabled={isUpdating}
                                className="font-mono text-lg"
                            />
                        </div>

                        {/* Validation Feedback */}
                        {validation && (
                            <>
                                {validation.isOk ? (
                                    <Alert className="bg-green-50 border-green-200 dark:bg-green-950/30 dark:border-green-900">
                                        <AlertCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
                                        <AlertDescription className="text-green-800 dark:text-green-200">
                                            ✓ Weight OK ({measuredWeight}g). Set will be marked as <strong>ACTIVE</strong> and returned to stock.
                                        </AlertDescription>
                                    </Alert>
                                ) : (
                                    <Alert className="bg-orange-50 border-orange-200 dark:bg-orange-950/30 dark:border-orange-900">
                                        <AlertCircle className="h-5 w-5 text-orange-600 dark:text-orange-400" />
                                        <AlertDescription className="text-orange-800 dark:text-orange-200">
                                            ⚠ Weight out of range ({measuredWeight}g, difference: {validation.difference > 0 ? '+' : ''}{validation.difference}g).
                                            Set will be marked as <strong>IN REPAIR</strong> for missing pieces inspection.
                                        </AlertDescription>
                                    </Alert>
                                )}
                            </>
                        )}

                        {!validation && measuredWeight && (
                            <Alert className="bg-red-50 border-red-200 dark:bg-red-950/30 dark:border-red-900">
                                <AlertCircle className="h-5 w-5 text-red-600 dark:text-red-400" />
                                <AlertDescription className="text-red-800 dark:text-red-200">
                                    Please enter a valid weight.
                                </AlertDescription>
                            </Alert>
                        )}
                    </div>

                    <DialogFooter>
                        <Button
                            variant="outline"
                            onClick={() => setIsDialogOpen(false)}
                            disabled={isUpdating}
                        >
                            Cancel
                        </Button>
                        <Button
                            onClick={handleConfirmUpdate}
                            disabled={isConfirmDisabled}
                        >
                            {isUpdating && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Confirm & Process
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
};

export default ReturnsList;