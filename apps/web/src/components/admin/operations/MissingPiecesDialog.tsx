import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Loader2, X, AlertCircle } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { Alert, AlertDescription } from "@/components/ui/alert";

interface MissingPiece {
    piece_ref: string;
    quantity: number;
}

interface MissingPiecesDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    setId: string;
    setRef: string;
}

const MissingPiecesDialog = ({
    open,
    onOpenChange,
    setId,
    setRef,
}: MissingPiecesDialogProps) => {
    const [pieceRef, setPieceRef] = useState("");
    const [quantity, setQuantity] = useState("");
    const [pieces, setPieces] = useState<MissingPiece[]>([]);
    const [isSaving, setIsSaving] = useState(false);
    const { toast } = useToast();

    const handleAddPiece = () => {
        const ref = pieceRef.trim();
        const qty = parseInt(quantity, 10);

        if (!ref) {
            toast({
                title: "Invalid input",
                description: "Please enter a piece reference.",
                variant: "destructive",
            });
            return;
        }

        if (isNaN(qty) || qty <= 0) {
            toast({
                title: "Invalid quantity",
                description: "Please enter a valid quantity greater than 0.",
                variant: "destructive",
            });
            return;
        }

        // Check if piece already exists
        const existingIndex = pieces.findIndex((p) => p.piece_ref === ref);
        if (existingIndex !== -1) {
            // Update existing piece
            const updatedPieces = [...pieces];
            updatedPieces[existingIndex].quantity += qty;
            setPieces(updatedPieces);
        } else {
            // Add new piece
            setPieces([...pieces, { piece_ref: ref, quantity: qty }]);
        }

        // Reset inputs
        setPieceRef("");
        setQuantity("");
    };

    const handleRemovePiece = (index: number) => {
        setPieces(pieces.filter((_, i) => i !== index));
    };

    const handleSave = async () => {
        if (pieces.length === 0) {
            toast({
                title: "No pieces added",
                description: "Please add at least one missing piece.",
                variant: "destructive",
            });
            return;
        }

        setIsSaving(true);
        try {
            // Call RPC function to add missing pieces batch
            const { data, error } = await supabase.rpc(
                "add_missing_pieces_batch",
                {
                    p_set_id: setId,
                    p_pieces: pieces,
                }
            );

            if (error) throw error;

            const result = data as any;
            if (!result.success) {
                throw new Error(result.error || "Unknown error");
            }

            toast({
                title: "Missing pieces recorded",
                description: `${result.inserted_count} piece(s) added to repair queue.`,
                className: "bg-green-100 border-green-200 dark:bg-green-900/30 dark:border-green-800",
            });

            // Reset and close
            setPieces([]);
            setPieceRef("");
            setQuantity("");
            onOpenChange(false);
        } catch (error: any) {
            console.error("Error saving missing pieces:", error);
            toast({
                title: "Error",
                description: error.message || "Could not save missing pieces.",
                variant: "destructive",
            });
        } finally {
            setIsSaving(false);
        }
    };

    const handleClose = () => {
        if (pieces.length > 0) {
            if (
                !confirm(
                    "You have unsaved changes. Are you sure you want to close?"
                )
            ) {
                return;
            }
        }
        setPieces([]);
        setPieceRef("");
        setQuantity("");
        onOpenChange(false);
    };

    return (
        <Dialog open={open} onOpenChange={handleClose}>
            <DialogContent className="max-w-2xl">
                <DialogHeader>
                    <DialogTitle>Register Missing Pieces</DialogTitle>
                    <DialogDescription>
                        Record missing or damaged pieces for set <strong>{setRef}</strong>.
                        Add each missing piece reference and quantity.
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-6 py-4">
                    {/* Input Section */}
                    <div className="space-y-4 p-4 bg-muted/30 rounded-lg border border-muted">
                        <div className="grid grid-cols-2 gap-3">
                            <div className="space-y-2">
                                <Label htmlFor="piece-ref">Piece Reference</Label>
                                <Input
                                    id="piece-ref"
                                    placeholder="e.g., 3001, 3002"
                                    value={pieceRef}
                                    onChange={(e) => setPieceRef(e.target.value)}
                                    disabled={isSaving}
                                    onKeyPress={(e) => {
                                        if (e.key === "Enter") {
                                            handleAddPiece();
                                        }
                                    }}
                                />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="quantity">Quantity</Label>
                                <Input
                                    id="quantity"
                                    type="number"
                                    min="1"
                                    placeholder="0"
                                    value={quantity}
                                    onChange={(e) => setQuantity(e.target.value)}
                                    disabled={isSaving}
                                    onKeyPress={(e) => {
                                        if (e.key === "Enter") {
                                            handleAddPiece();
                                        }
                                    }}
                                />
                            </div>
                        </div>
                        <Button
                            onClick={handleAddPiece}
                            disabled={isSaving}
                            variant="secondary"
                            className="w-full"
                        >
                            Add to List
                        </Button>
                    </div>

                    {/* Pieces List */}
                    {pieces.length > 0 ? (
                        <div className="space-y-3">
                            <div className="flex items-center justify-between">
                                <h4 className="font-medium text-sm">
                                    Registered Pieces ({pieces.length})
                                </h4>
                                <span className="text-xs text-muted-foreground">
                                    Total: {pieces.reduce((sum, p) => sum + p.quantity, 0)} pieces
                                </span>
                            </div>
                            <div className="rounded-md border overflow-hidden">
                                <Table>
                                    <TableHeader>
                                        <TableRow className="bg-muted/50">
                                            <TableHead>Piece Ref</TableHead>
                                            <TableHead className="text-right">Qty</TableHead>
                                            <TableHead className="w-12"></TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {pieces.map((piece, index) => (
                                            <TableRow key={index}>
                                                <TableCell className="font-mono font-bold">
                                                    {piece.piece_ref}
                                                </TableCell>
                                                <TableCell className="text-right">
                                                    {piece.quantity}
                                                </TableCell>
                                                <TableCell className="text-center">
                                                    <Button
                                                        variant="ghost"
                                                        size="icon"
                                                        onClick={() => handleRemovePiece(index)}
                                                        disabled={isSaving}
                                                        className="h-7 w-7"
                                                    >
                                                        <X className="h-3 w-3" />
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            </div>
                        </div>
                    ) : (
                        <Alert>
                            <AlertCircle className="h-4 w-4" />
                            <AlertDescription>
                                No pieces added yet. Add missing pieces using the form above.
                            </AlertDescription>
                        </Alert>
                    )}
                </div>

                <DialogFooter>
                    <Button
                        variant="outline"
                        onClick={handleClose}
                        disabled={isSaving}
                    >
                        Cancel
                    </Button>
                    <Button
                        onClick={handleSave}
                        disabled={isSaving || pieces.length === 0}
                    >
                        {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                        Confirm & Save
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
};

export default MissingPiecesDialog;